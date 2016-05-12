//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class CallStateOutgoing: CallState {

    override var status: Call.Status {
        return .Ringing
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
        call.hangup(nil)
        call.state = CallStateRemoteDeclined(call)
        postNotification(Notifications.Call.Disconnected)
    }
}