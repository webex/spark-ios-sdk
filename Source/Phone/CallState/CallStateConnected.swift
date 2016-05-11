//
//  CallStateConnected.swift
//  Pods
//
//  Created by niliu2 on 3/25/16.
//
//

import Foundation

class CallStateConnected: CallState {

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