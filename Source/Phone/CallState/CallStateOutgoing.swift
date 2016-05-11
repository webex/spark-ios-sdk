//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class CallStateOutgoing: CallState {

    override var status: Call.Status {
        return .Ringing
    }
    
    override func isAllowedToHangup() -> Bool {
        return true
    }
    
    override func isAllowedToOperateMedia() -> Bool {
        return true
    }
    
    override func update() {
        if info.hasLeft {
            doActionWhenLocalCancelled()
        } else if info.hasAtLeastOneRemoteParticipantantJoined {
            doActionWhenConnected()
        } else if info.hasAtLeastOneRemoteParticipantantDeclined {
            doActionWhenRemoteDeclined()
        }
    }
    
    private func doActionWhenConnected() {
        call.state = CallStateConnected(call)
        postNotification(Notifications.Call.Connected)
    }
    
    private func doActionWhenLocalCancelled() {
        callManager.removeCall(call.url)
        call.state = CallStateLocalCancelled(call)
        postNotification(Notifications.Call.Disconnected)
    }
    
    private func doActionWhenRemoteDeclined() {
        callManager.removeCall(call.url)
        call.hangup()
        call.state = CallStateRemoteDeclined(call)
        postNotification(Notifications.Call.Disconnected)
    }
}