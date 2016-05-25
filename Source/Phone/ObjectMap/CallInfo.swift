// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import ObjectMapper

struct CallInfo: Mappable {
    var callUrl: String?
    var participants: [Participant]?
    var myself: Participant?
    var host: ParticipantInfo?
    var fullState: FullState?
    var sequence: Sequence?
    
    var selfEmail: String? {
        return myself?.person?.email
    }
    
    var hostEmail: String? {
        return host?.email
    }

    var allDevices: [ParticipantDevice] {
        return allParticipantants.flatMap({$0.devices}).reduce([], combine: +)
    }
    
    var selfDevices: [ParticipantDevice] {
        guard let devices = myself?.devices else {
            return []
        }
        return devices
    }
    
    var thisDevice: ParticipantDevice? {
        return selfDevices.filter({$0.url == DeviceService.sharedInstance.deviceUrl}).first // should be only one
    }
    
    var otherDevices: [ParticipantDevice] {
        return selfDevices.filter({$0.url != DeviceService.sharedInstance.deviceUrl})
    }
    
    var remoteDevices: [ParticipantDevice] {
        return remoteParticipantants.flatMap({$0.devices}).reduce([], combine: +)
    }

    var allParticipantants: [Participant] {
        guard let allParticipants = participants else {
            return []
        }
        
        return allParticipants
    }

    var selfParticipantant: Participant? {
        return myself
    }
    
    var remoteParticipantants: [Participant] {
        
        return allParticipantants.filter({$0.id != myself?.id})
    }
    
    var selfMediaInfo: MediaInfo? {
        return thisDevice?.mediaConnections?.first?.localSdp
    }
    
    var selfMediaUrl: String? {
        return myself?.mediaBaseUrl
    }
    
    var selfParticipantUrl: String? {
        return myself?.url
    }
    
    var selfId: String? {
        return myself?.id
    }
    
    var selfState: ParticipantState? {
        return myself?.state
    }
    
    var selfAudioMuted: Bool? {
        return selfMediaInfo?.audioMuted
    }
    
    var selfVideoMuted: Bool? {
        return selfMediaInfo?.videoMuted
    }
    
    var remoteSdp: String? {
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
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        callUrl <- map["url"]
        participants <- map["participants"]
        myself <- map["self"]
        host <- map["host"]
        fullState <- map["fullState"]
        sequence <- map["sequence"]
    }
}