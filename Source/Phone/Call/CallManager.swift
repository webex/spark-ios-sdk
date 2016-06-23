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
    
    // TODO: need to check in which case call is active
    func getActiveCall() -> Call? {
        for call in callInstances.values {
            if call.status == Call.Status.Connected {
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