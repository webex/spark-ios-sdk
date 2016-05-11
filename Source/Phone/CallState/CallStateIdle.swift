//
//  CallStateIdle.swift
//  Pods
//
//  Created by niliu2 on 3/25/16.
//
//

import Foundation

class CallStateIdle: CallState {
    
    override func isAllowedToDial() -> Bool {
        return true
    }

    override func update() {
        if isMakingOutgoingCall() {
            doActionWhenOutgoing()
        }
    }
    
    private func isMakingOutgoingCall() -> Bool {
        return info.hasJoinedOnThisDevice && isRemoteParticipantantsIdleOrNotified()
    }
    
    private func isRemoteParticipantantsIdleOrNotified() -> Bool {
        return info.remoteParticipantants.filter({$0.state != ParticipantState.Idle && $0.state != ParticipantState.Notified}).isEmpty
    }
    
    private func doActionWhenOutgoing() {
        call.state = CallStateOutgoing(call)
        postNotification(Notifications.Call.Ringing)
    }
}
