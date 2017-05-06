// Copyright 2016-2017 Cisco Systems Inc
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
    
    private var queue = [(event: String, completionHandler: ((Error?) -> Void)?)]()
    
    private let dispatchQueue = DispatchQueue(label: "CallDtmfQueueDispatchQueue")
    
    private var correlationId: Int = 1
    
    private var waitingForResponse = false;
    
    private let client: CallClient

    init(client: CallClient) {
        self.client = client
    }
    
    func push(participantUrl: String, device: Device, event: String, completionHandler: ((Error?) -> Void)?) {
        if isValidEvents(event) {
            dispatchQueue.async {
                self.queue.append((event, completionHandler))
                self.sendDtmfEvents(participantUrl: participantUrl, device: device, completionHandler: completionHandler)
            }
        } else {
            DispatchQueue.main.async {
                completionHandler?(SparkError.invalidDTMF)
            }
        }
    }
    
    private func sendDtmfEvents(participantUrl: String, device: Device, completionHandler: ((Error?) -> Void)?) {
        dispatchQueue.async {
            if self.queue.count > 0 && !self.waitingForResponse {
                var events = [String]()
                var completionHandlers = [((Error?) -> Void)?]()
                for item in self.queue {
                    events.append(item.event)
                    completionHandlers.append(item.completionHandler)
                }
                let dtmfEvents = events.joined(separator: "")
                SDKLogger.info("send Dtmf events \(dtmfEvents)")
                
                self.waitingForResponse = true
                self.client.sendDtmf(participantUrl, by: device, correlationId: self.correlationId, events: dtmfEvents, queue: self.dispatchQueue) {
                    switch $0.result {
                    case .success:
                        SDKLogger.info("Success: send Dtmf with correlationId \(self.correlationId - 1)")
                        for completion in completionHandlers {
                            DispatchQueue.main.async {
                                completion?(nil)
                            }
                        }
                    case .failure(let error):
                        SDKLogger.error("Failure", error: error)
                        for completion in completionHandlers {
                            DispatchQueue.main.async {
                                completion?(error)
                            }
                        }
                    }
                    self.waitingForResponse = false
                    self.sendDtmfEvents(participantUrl: participantUrl, device: device, completionHandler: completionHandler)
                }
                self.correlationId += 1
                self.queue.removeAll()
            }
        }
    }
    
    private func isValidEvents(_ events: String) -> Bool {
        let characterset = CharacterSet(charactersIn: "1234567890*#ABCDabcd")
        if events.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        } else {
            return true
        }
    }
}
