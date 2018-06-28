// Copyright 2016-2018 Cisco Systems Inc
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
import Sbu

@available(iOS 11.2,*)
class SparkBroadcastClient : BroadcastConnectionClientDelegate{
    private static let MAX_SUSPEND_TIMES: Int = 10
    
    private var applicationGroupIdentifier: String?
    private var suspendCount: Int = 0
    private var connectionClient: BroadcastConnectionClient?
    
    var onError: ((SparkError) -> Void)?
    var onStateChange: ((BroadcastExtensionState) -> Void)?
    var broadcastState: BroadcastExtensionState = .Initiated {
        didSet {
            self.onStateChange?(self.broadcastState)
        }
    }
    
    init(applicationGroupIdentifier:String) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
    }
    
    func didReceivedError(_ error: ScreenShareError) {
        switch error {
        case .fatal:
            self.onError?(SparkError.serviceFailed(code: -7000, reason: "Spark Broadcast server fatal error"))
            break
        case .noCallIsActive:
            self.onError?(SparkError.illegalStatus(reason: "Screen share failure due to no call is active."))
            self.invalidateClient()
            break
        case .stop:
            self.invalidateClient()
            break
        default:
            self.onError?(SparkError.serviceFailed(code: -7000, reason: "Spark Broadcast server fatal error"))
        }
    }
    
    func didFail(toSendFrame error: ScreenShareError) {
        switch error {
        case .frameProcessingSuspended:
            suspendCount += 1
            if suspendCount > SparkBroadcastClient.MAX_SUSPEND_TIMES {
                suspendCount = 0
                self.onError?(SparkError.serviceFailed(code: -7000, reason: "Spark Broadcast server suspended"))
                if self.broadcastState == .Broadcasting {
                    self.broadcastState = .Suspended
                }
            }
            break
        case .none:
            suspendCount = 0
            if self.broadcastState == .Suspended {
                self.broadcastState = .Broadcasting
            }
            break
        case .fatal:
            suspendCount = 0
            if self.broadcastState == .Suspended {
                self.broadcastState = .Broadcasting
            }
            if self.broadcastState == .Suspended || self.broadcastState == .Broadcasting {
                self.onError?(SparkError.serviceFailed(code: -7000, reason: "Screen share sending frame failed"))
            }
            break
        default:
            break
        }
    }
    
    func start(completionHandler: @escaping ((SparkError?) -> Void)) {
        if self.connectionClient == nil {
            self.connectionClient = BroadcastConnectionClient.init(applicationGroupIdentifier: applicationGroupIdentifier, delegate: self)
        }
        
        if self.broadcastState == .Broadcasting || self.broadcastState == .Suspended {
            completionHandler(nil)
            return
        }
        
        self.connectionClient?.start() {
            error in
            if error != nil {
                completionHandler(SparkError.illegalStatus(reason: "Screen share failure due to no call is active."))
                self.broadcastState = .Stopped
            } else {
                completionHandler(nil)
                self.broadcastState = .Broadcasting
            }
        }
    }
    
    func pushVideoSampleBuffer(sampleBuffer:CMSampleBuffer) {
        if self.broadcastState == .Broadcasting {
            self.connectionClient?.push(sampleBuffer)
        }
    }
    
    func finishClient() {
        if self.broadcastState == .Broadcasting || self.broadcastState == .Suspended {
            var message = FrameMessage()
            message.error = ScreenShareError.stop;
            let data = Data(bytes: &message, count: MemoryLayout<FeedbackMessage>.size)
            self.connectionClient?.sendMessage(data) {
                error in
                if error != nil {
                    self.onError?(SparkError.serviceFailed(code: -7000, reason: "Screen share sending message failed"))
                }
            }
            self.invalidateClient()
        }
    }
    
    func invalidateClient() {
        if self.broadcastState == .Broadcasting || self.broadcastState == .Suspended {
            self.connectionClient?.invalidate()
            self.broadcastState = .Stopped
        }
    }
}
