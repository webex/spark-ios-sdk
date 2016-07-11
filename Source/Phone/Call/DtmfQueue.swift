// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

class DtmfQueue {
    
    typealias CompletionHandler = Bool -> Void
    
    var queue: [(event: String, completionHandler: CompletionHandler?)]
    let dispatchQueue: dispatch_queue_t
    weak var call: Call!
    var correlationId: Int
    var waitingForResponse: Bool
    
    private let deviceUrl = DeviceService.sharedInstance.deviceUrl
    
    init(_ call: Call) {
        queue = []
        correlationId = 1
        self.call = call
        dispatchQueue = dispatch_queue_create("CallDtmfQueueDispatchQueue", DISPATCH_QUEUE_SERIAL)
        waitingForResponse = false
    }
    
    func isValidEvents(events: String) -> Bool {
        let characterset = NSCharacterSet(charactersInString: "1234567890*#ABCDabcd")
        if events.rangeOfCharacterFromSet(characterset.invertedSet) != nil {
            return false
        } else {
            return true
        }
    }
    
    func push(event: String, completionHandler: CompletionHandler?) {
        if isValidEvents(event) {
            dispatch_async(dispatchQueue) {
                self.queue.append((event, completionHandler))
                self.sendDtmfEvents(completionHandler)
            }
        } else {
            if let handler = completionHandler {
                handler(false)
            }
        }
    }
    
    func sendDtmfEvents(completionHandler: CompletionHandler?) {
        dispatch_async(dispatchQueue) {
            if self.queue.count > 0 && !self.waitingForResponse {
                var events = [String]()
                var completionHandlers = [CompletionHandler?]()
                for item in self.queue {
                    events.append(item.event)
                    completionHandlers.append(item.completionHandler)
                }
                
                let dtmfEvents = events.joinWithSeparator("")
                Logger.info("send Dtmf events \(dtmfEvents)")
                
                let participantUrl = self.call.info?.selfParticipantUrl
                self.waitingForResponse = true
                CallClient().sendDtmf(participantUrl!, deviceUrl: self.deviceUrl!, correlationId: self.correlationId, events: dtmfEvents, queue: self.dispatchQueue) {
                    switch $0.result {
                    case .Success:
                        Logger.info("Success: send Dtmf with correlationId \(self.correlationId - 1)")
                        for completion in completionHandlers {
                            dispatch_async(dispatch_get_main_queue()) {
                                completion?(true)
                            }
                        }
                    case .Failure(let error):
                        Logger.error("Failure: \(error.localizedFailureReason)")
                        for completion in completionHandlers {
                            dispatch_async(dispatch_get_main_queue()) {
                                completion?(false)
                            }
                        }
                    }
                    self.waitingForResponse = false
                    self.sendDtmfEvents(completionHandler)
                }
                self.correlationId += 1
                self.queue.removeAll()
            }
        }
    }
}