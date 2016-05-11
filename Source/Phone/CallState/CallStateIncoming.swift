//
//  CallStateIncoming.swift
//  Pods
//
//  Created by niliu2 on 3/25/16.
//
//

import Foundation

class CallStateIncoming: CallState {

    override func isAllowedToAnswer() -> Bool {
        return true
    }

    override func isAllowedToReject() -> Bool {
        return true
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
        postNotification(Notifications.Call.Connected)
    }
    
    private func doActionWhenLocalDeclined() {
        callManager.removeCall(call.url)
        call.state = CallStateLocalDeclined(call)
        postNotification(Notifications.Call.Disconnected)
    }
    
    private func doActionWhenOtherDeviceConnected() {
        callManager.removeCall(call.url)
        call.state = CallStateOtherDeviceConnected(call)
        postNotification(Notifications.Call.Connected)
    }
    
    private func doActionWhenOtherDeviceDeclined() {
        callManager.removeCall(call.url)
        call.state = CallStateOtherDeviceDeclined(call)
        postNotification(Notifications.Call.Disconnected)
    }
    
    private func doActionWhenRemoteCancelled() {
        callManager.removeCall(call.url)
        call.state = CallStateRemoteCancelled(call)
        postNotification(Notifications.Call.Disconnected)
    }
}