//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class CallStateIdle: CallState {
    
    override var status: Call.Status {
        return .Initiated
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
