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

class CallStateIncoming: CallState {

    override var status: Call.Status {
        return .Incoming
    }
    
    override func update() {
        if info.hasAtLeastOneRemoteParticipantantJoined {
            if info.hasJoinedOnThisDevice {
                doActionWhenConnected()
            } else if info.hasJoinedOnOtherDevice {
                doActionWhenOtherDeviceConnected()
            } else if info.hasDeclined {
                doActionWhenLocalDeclined()
            } else if info.hasDeclinedOnOtherDevice {
                doActionWhenOtherDeviceDeclined()
            }
        } else if info.hasAtLeastOneRemoteParticipantantLeft {
            doActionWhenRemoteCancelled()
        }
    }

    private func doActionWhenConnected() {
        call.state = CallStateConnected(call)
        callNotificationCenter.notifyCallConnected(call)
    }
    
    private func doActionWhenLocalDeclined() {
        callManager.removeCall(call.url)
        call.state = CallStateLocalDeclined(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.LocalDeclined)
    }
    
    private func doActionWhenOtherDeviceConnected() {
        callManager.removeCall(call.url)
        call.state = CallStateOtherDeviceConnected(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.OtherDeviceConnected)
    }
    
    private func doActionWhenOtherDeviceDeclined() {
        callManager.removeCall(call.url)
        call.state = CallStateOtherDeviceDeclined(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.OtherDeviceDeclined)
    }
    
    private func doActionWhenRemoteCancelled() {
        callManager.removeCall(call.url)
        call.state = CallStateRemoteCancelled(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.RemoteCancelled)
    }
}