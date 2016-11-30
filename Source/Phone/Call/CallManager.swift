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

class CallManager {
    
    private var callInstances = [String: Call]()
    private let authenticationStrategy: AuthenticationStrategy
    
    init(authenticationStrategy: AuthenticationStrategy) {
        self.authenticationStrategy = authenticationStrategy
    }
    
    func addCallWith(url: String, call: Call) {
        guard url.characters.count > 0 else { return }
		
        callInstances.updateValue(call, forKey: url)
        Logger.info("Add call for call url:\(url)")
    }
    
    func removeCallWith(url: String) {
        callInstances.removeValue(forKey: url)
        Logger.info("Remove call for call url:\(url)")
    }
    
    func findCallBy(mediaSession session: MediaSession) -> Call? {
        for call in callInstances.values {
            if call.isMediaSessionAssociated(session) {
                return call
            }
        }
        return nil
    }
    
    func fetchActiveCalls() {
        Logger.info("Fetch call infos")
        CallClient(authenticationStrategy: authenticationStrategy).fetchCallInfos() {
            switch $0.result {
            case .success(let callInfos):
                for callInfo in callInfos {
                    self.handle(callInfo: callInfo)
                }
                Logger.info("Success: fetch call infos")
            case .failure(let error):
                Logger.error("Failure", error: error)
            }
        }
    }
    
    func handle(callInfo: CallInfo) {
        guard let callUrl = callInfo.callUrl else {
            return
        }
        
        // TODO: support room call
        guard callInfo.isOneOnOne else {
            return
        }
        
        // If it belongs to existing active call, update it.
        if let call = callInstances[callUrl] {
            call.update(callInfo: callInfo)
            return
        }
        
        if callInfo.isIncomingCall {
            doActionWhenIncoming(callInfo)
        } else if callInfo.hasJoinedOnOtherDevice {
            doActionWhenJoinedOnOtherDevice(callInfo)
        }
    }
    
    func createOutgoingCall() -> Call {
        return Call(authenticationStrategy: authenticationStrategy, callManager: self)
    }

    private func doActionWhenIncoming(_ callInfo: CallInfo) {
        let incomingCall = Call(callInfo, authenticationStrategy: authenticationStrategy, callManager: self)
        addCallWith(url: incomingCall.url, call: incomingCall)

        PhoneNotificationCenter.sharedInstance.notifyIncomingCall(incomingCall)
        
        Logger.info("Receive incoming call")
    }
    
    private func doActionWhenJoinedOnOtherDevice(_ callInfo: CallInfo) {
        // TODO: need to support other device joined case
        let call = Call(callInfo, authenticationStrategy: authenticationStrategy, callManager: self)
        addCallWith(url: call.url, call: call)
    }
}
