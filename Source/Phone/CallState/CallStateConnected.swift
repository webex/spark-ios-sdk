//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class CallStateConnected: CallState {
    
    override var status: Call.Status {
        return .Connected
    }

    override func isAllowedToHangup() -> Bool {
        return true
    }

    override func isAllowedToOperateMedia() -> Bool {
        return true
    }
    
    override func update() {
        if info.hasLeft {
            doActionWhenLocalLeft()
        } else if info.hasAtLeastOneRemoteParticipantantLeft {
            doActionWhenRemoteLeft()
        }
    }
    
    private func doActionWhenLocalLeft() {
        callManager.removeCall(call.url)
        call.state = CallStateLocalLeft(call)
        postNotification(Notifications.Call.Disconnected)
    }
    
    private func doActionWhenRemoteLeft() {
        callManager.removeCall(call.url)
        call.hangup()
        call.state = CallStateRemoteLeft(call)
        postNotification(Notifications.Call.Disconnected)
    }
}