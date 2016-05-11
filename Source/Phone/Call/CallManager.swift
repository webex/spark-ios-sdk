//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import ObjectMapper

class CallManager: NotificationObserver {
    
    static let sharedInstance = CallManager()
    private var callInstances = [String: Call]()
    
    func addCall(url: String, call: Call) {
        callInstances.updateValue(call, forKey: url)
        print("addCall: call url:\(url)")
    }
    
    func removeCall(url: String) {
        callInstances.removeValueForKey(url)
        print("removeCall: call url:\(url)")
    }
    
    // TODO: need to check in which case call is active
    func getActiveCall() -> Call? {
        for call in callInstances.values {
            return call
        }
        
        return nil
    }
    
    override func getNotificationHandlerMap() -> [String: String] {
        return [
            Notifications.Locus.ParticipantJoined:                  "handleCallEvent:",
            Notifications.Locus.ParticipantLeft:                    "handleCallEvent:",
            Notifications.Locus.ParticipantDeclined:                "handleCallEvent:",
            Notifications.Locus.ParticipantAlerted:                 "handleCallEvent:",
            Notifications.Locus.ParticipantUpdated:                 "handleCallEvent:",
            Notifications.Locus.ParticipantRolesUpdated:            "handleCallEvent:",
            Notifications.Locus.ParticipantControlsUpdated:         "handleCallEvent:",
            Notifications.Locus.ParticipantAudioMuted:              "handleCallEvent:",
            Notifications.Locus.ParticipantAudioUnmuted:            "handleCallEvent:",
            Notifications.Locus.ParticipantVideoMuted:              "handleCallEvent:",
            Notifications.Locus.ParticipantVideoUnmuted:            "handleCallEvent:",
            Notifications.Locus.ParticipantBroadcast:               "handleCallEvent:",
            Notifications.Locus.ParticipantAudioConnectionCreated:  "handleCallEvent:",
            Notifications.Locus.ParticipantVideoConnectionCreated:  "handleCallEvent:",
            Notifications.Locus.ParticipantMediaConnectionModified: "handleCallEvent:",
            Notifications.Locus.SelfChanged:                        "handleCallEvent:",
            Notifications.Locus.FloorGranted:                       "handleCallEvent:",
            Notifications.Locus.FloorReleased:                      "handleCallEvent:",
            Notifications.Locus.SpaceUsersModified:                 "handleCallEvent:",
            Notifications.Locus.ControlsUpdated:                    "handleCallEvent:"]
    }
    
    private func isOneOnOneCall(event: NSNotification) -> Bool {
        if let callInfo = event.callInfo {
            return callInfo.isOneOnOne
        }
        return false
    }
    
    private func isIncomingCall(event: NSNotification) -> Bool {
        guard let callInfo = event.callInfo else {
            return false
        }
        return callInfo.fullState?.state == "ACTIVE" && callInfo.myself?.alertType?.action == "FULL"
    }
    
    @objc private func handleCallEvent(event: NSNotification) {
        // TODO: support room call
        guard isOneOnOneCall(event) else {
            return
        }
        
        guard let callInfo = event.callInfo else {
            return
        }
        
        if isIncomingCall(event) {
            doActionWhenIncoming(event)
        } else {
            if let call = callInstances[getCallUrl(event)] {
                call.updateCallInfo(callInfo)
            }
        }
    }
    
    private func getCallUrl(event: NSNotification) -> String {
        if let callUrl = event.callInfo?.callUrl {
            return callUrl
        }
        
        return ""
    }

    private func doActionWhenIncoming(event: NSNotification) {
        if let callInfo = event.callInfo {
            let incomingCall = Call(callInfo)
            addCall(incomingCall.url, call: incomingCall)
            let userInfo = [Notifications.Phone.IncomingCallObjectKey: incomingCall]
            notificationCenter.postNotificationName(Notifications.Phone.Incoming, object: Phone.sharedInstance, userInfo: userInfo)
            
            print("doActionWhenIncoming")
        }
    }
}