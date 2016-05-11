//
//  CallInfo.swift
//  Pods
//
//  Created by bxu3 on 3/21/16.
//
//

import Foundation
import ObjectMapper

// TODO: may not need public
public struct CallInfo: Mappable {
    public var callUrl: String?
    public var participants: [Participant]?
    public var myself: Participant?
    public var host: ParticipantInfo?
    var fullState: FullState?
    public var sequence: Sequence?
    
    public var selfEmail: String? {
        return myself?.person?.email
    }
    
    public var hostEmail: String? {
        return host?.email
    }

    public var allDevices: [ParticipantDevice] {
        return allParticipantants.flatMap({$0.devices}).reduce([], combine: +)
    }
    
    public var selfDevices: [ParticipantDevice] {
        guard let devices = myself?.devices else {
            return []
        }
        return devices
    }
    
    public var thisDevice: ParticipantDevice? {
        return selfDevices.filter({$0.url == DeviceService.sharedInstance.deviceUrl}).first // should be only one
    }
    
    public var otherDevices: [ParticipantDevice] {
        return selfDevices.filter({$0.url != DeviceService.sharedInstance.deviceUrl})
    }
    
    public var remoteDevices: [ParticipantDevice] {
        return remoteParticipantants.flatMap({$0.devices}).reduce([], combine: +)
    }

    public var allParticipantants: [Participant] {
        guard let allParticipants = participants else {
            return []
        }
        
        return allParticipants
    }

    public var selfParticipantant: Participant? {
        return myself
    }
    
    public var remoteParticipantants: [Participant] {
        
        return allParticipantants.filter({$0.id != myself?.id})
    }
    
    public var selfMediaInfo: MediaInfo? {
        return thisDevice?.mediaConnections?.first?.localSdp
    }
    
    public var selfMediaUrl: String? {
        return myself?.mediaBaseUrl
    }
    
    public var selfParticipantUrl: String? {
        return myself?.url
    }
    
    public var selfId: String? {
        return myself?.id
    }
    
    public var selfState: ParticipantState? {
        return myself?.state
    }
    
    public var selfAudioMuted: Bool? {
        return selfMediaInfo?.audioMuted
    }
    
    public var selfVideoMuted: Bool? {
        return selfMediaInfo?.videoMuted
    }
    
    public var remoteSdp: String? {
        return thisDevice?.mediaConnections?.first?.remoteSdp?.sdp
    }
    
    var lastActive: String? {
        return fullState?.lastActive
    }
    
    var isOneOnOne: Bool {
        return allParticipantantsWithType("USER").count == 2
    }
    
    var isBridge: Bool {
        return !isOneOnOne
    }
    
    var hasJoined: Bool {
        return myself?.state == ParticipantState.Joined
    }

    var hasJoinedOnThisDevice: Bool {
        if !hasJoined {
            return false
        }
        return !(selfDevicesWithState("JOINED").filter({$0.url == DeviceService.sharedInstance.deviceUrl}).isEmpty)
    }

    var hasJoinedOnOtherDevice: Bool {
        if !hasJoined {
            return false
        }
        
        return  (selfDevicesWithState("JOINED").count > 1 )
            || (selfDevicesWithState("JOINED").filter({$0.url == DeviceService.sharedInstance.deviceUrl}).isEmpty)
    }

    var hasLeft: Bool {
        return selfParticipantant?.state == ParticipantState.Left
    }

    var hasDeclined: Bool {
        if selfParticipantant?.state != ParticipantState.Declined {
            return false
        }
        return selfParticipantant?.deviceUrl == DeviceService.sharedInstance.deviceUrl
    }

    var hasDeclinedOnOtherDevice: Bool {
        if selfParticipantant?.state != ParticipantState.Declined {
            return false
        }
        return selfParticipantant?.deviceUrl != DeviceService.sharedInstance.deviceUrl
    }

    var hasAtLeastOneRemoteParticipantantLeft: Bool {
        return remoteParticipantants.filter({$0.state == ParticipantState.Left}).count >= 1
    }

    var hasAtLeastOneRemoteParticipantantJoined: Bool {
        return remoteParticipantants.filter({$0.state == ParticipantState.Joined}).count >= 1
    }
    
    var hasAtLeastOneRemoteParticipantantDeclined: Bool {
        return remoteParticipantants.filter({$0.state == ParticipantState.Declined}).count >= 1
    }

    // MARK: utils functions
    func participantsContiansEmailDomain(emailDomain: String) -> Bool {
        return allParticipantants.filter({
            guard let email = $0.person?.email else {
                return false
            }
            return email.lowercaseString.hasSuffix(emailDomain.lowercaseString)
        }).count > 0
    }
    
    func allParticipantantsWithType(type: String) -> [Participant] {
        return allParticipantants.filter({$0.type == type})
    }
    
    func selfDevicesWithState(state: String) -> [ParticipantDevice] {
        return selfDevices.filter({$0.state == state})
    }
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        callUrl <- map["url"]
        participants <- map["participants"]
        myself <- map["self"]
        host <- map["host"]
        fullState <- map["fullState"]
        sequence <- map["sequence"]
    }
}