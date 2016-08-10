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

import ObjectMapper

class CallManager {
    
    static let sharedInstance = CallManager()
    private var callInstances = [String: Call]()
    
    func addCall(url: String, call: Call) {
        callInstances.updateValue(call, forKey: url)
        Logger.info("Add call for call url:\(url)")
    }
    
    func removeCall(url: String) {
        callInstances.removeValueForKey(url)
        Logger.info("Remove call for call url:\(url)")
    }
    
    func findCallByMediaSession(session: MediaSession) -> Call? {
        for call in callInstances.values {
            if call.isMediaSessionAssociated(session) {
                return call
            }
        }
        return nil
    }
    
    func handleCallEvent(event: AnyObject) {
        guard let callEvent = Mapper<CallEvent>().map(event) else {
            return
        }
        
        guard let callInfo = callEvent.callInfo else {
            return
        }
        
        Logger.info(callEvent.type!)
        
        handleCallInfo(callInfo)
    }
    
    func fetchActiveCalls() {
        Logger.info("Fetch call infos")
        CallClient().fetchCallInfos() {
            switch $0.result {
            case .Success(let value):
                self.handleActiveCalls(value)
                Logger.info("Success: fetch call infos")
            case .Failure(let error):
                Logger.error("Failure: \(error.localizedFailureReason)")
            }
        }
    }
    
    private func handleCallInfo(callInfo: CallInfo) {
        guard let callUrl = callInfo.callUrl else {
            return
        }
        
        // TODO: support room call
        guard callInfo.isOneOnOne else {
            return
        }
        
        // If it belongs to existing active call, update it.
        if let call = callInstances[callUrl] {
            call.updateCallInfo(callInfo)
            return
        }
        
        if callInfo.isIncomingCall {
            doActionWhenIncoming(callInfo)
        } else if callInfo.hasJoinedOnOtherDevice {
            doActionWhenJoinedOnOtherDevice(callInfo)
        }
    }
    
    private func handleActiveCalls(callInfos: [CallInfo]) {
        for callInfo in callInfos {
            handleCallInfo(callInfo)
        }
    }

    private func doActionWhenIncoming(callInfo: CallInfo) {
        let incomingCall = Call(callInfo)
        addCall(incomingCall.url, call: incomingCall)

        PhoneNotificationCenter.sharedInstance.notifyIncomingCall(incomingCall)
        
        Logger.info("Receive incoming call")
    }
    
    private func doActionWhenJoinedOnOtherDevice(callInfo: CallInfo) {
        // TODO: need to support other device joined case
        let call = Call(callInfo)
        addCall(call.url, call: call)
    }
}