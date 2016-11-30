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
        call.removeFromCallManager()
        call.state = CallStateLocalDeclined(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.LocalDeclined)
    }
    
    private func doActionWhenOtherDeviceConnected() {
        call.removeFromCallManager()
        call.state = CallStateOtherDeviceConnected(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.OtherDeviceConnected)
    }
    
    private func doActionWhenOtherDeviceDeclined() {
        call.removeFromCallManager()
        call.state = CallStateOtherDeviceDeclined(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.OtherDeviceDeclined)
    }
    
    private func doActionWhenRemoteCancelled() {
        call.removeFromCallManager()
        call.state = CallStateRemoteCancelled(call)
        callNotificationCenter.notifyCallDisconnected(call, disconnectionType: DisconnectionType.RemoteCancelled)
    }
}
