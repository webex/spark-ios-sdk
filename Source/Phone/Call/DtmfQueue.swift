// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

class DtmfQueue {
    
    typealias CompletionHandler = (Bool) -> Void
    
    var queue: [(event: String, completionHandler: CompletionHandler?)]
    let dispatchQueue: DispatchQueue
    weak var call: Call!
    var correlationId: Int
    var waitingForResponse: Bool
    
    private let deviceUrl = DeviceService.sharedInstance.deviceUrl
    
    init(_ call: Call) {
        queue = []
        correlationId = 1
        self.call = call
        dispatchQueue = DispatchQueue(label: "CallDtmfQueueDispatchQueue")
        waitingForResponse = false
    }
    
    func isValidEvents(_ events: String) -> Bool {
        let characterset = CharacterSet(charactersIn: "1234567890*#ABCDabcd")
        if events.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        } else {
            return true
        }
    }
    
    func push(_ event: String, completionHandler: CompletionHandler?) {
        if isValidEvents(event) {
            dispatchQueue.async {
                self.queue.append((event, completionHandler))
                self.sendDtmfEvents(completionHandler)
            }
        } else {
            if let handler = completionHandler {
                handler(false)
            }
        }
    }
    
    func sendDtmfEvents(_ completionHandler: CompletionHandler?) {
        dispatchQueue.async {
            if self.queue.count > 0 && !self.waitingForResponse {
                var events = [String]()
                var completionHandlers = [CompletionHandler?]()
                for item in self.queue {
                    events.append(item.event)
                    completionHandlers.append(item.completionHandler)
                }
                
                let dtmfEvents = events.joined(separator: "")
                Logger.info("send Dtmf events \(dtmfEvents)")
                
                let participantUrl = self.call.info?.selfParticipantUrl
                self.waitingForResponse = true
                CallClient().sendDtmf(participantUrl!, deviceUrl: self.deviceUrl!, correlationId: self.correlationId, events: dtmfEvents, queue: self.dispatchQueue) {
                    switch $0.result {
                    case .success:
                        Logger.info("Success: send Dtmf with correlationId \(self.correlationId - 1)")
                        for completion in completionHandlers {
                            DispatchQueue.main.async {
                                completion?(true)
                            }
                        }
                    case .failure(let error):
                        Logger.error("Failure: \(error.localizedFailureReason)")
                        for completion in completionHandlers {
                            DispatchQueue.main.async {
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
