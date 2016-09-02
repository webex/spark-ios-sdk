// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
        return allParticipantants.flatMap({$0.devices}).reduce([], +)
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
        return remoteParticipantants.flatMap({$0.devices}).reduce([], +)
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
    
    var enableDTMF: Bool? {
        return selfParticipantant?.enableDTMF
    }
    
    var lastActive: String? {
        return fullState?.lastActive
    }
    
    var isOneOnOne: Bool {
		return allParticipantantsWith(type: "USER").count == 2
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
		return !(selfDevicesWith(state: "JOINED").filter({$0.url == DeviceService.sharedInstance.deviceUrl}).isEmpty)
    }

    var hasJoinedOnOtherDevice: Bool {
        if !hasJoined {
            return false
        }
        
		return  (selfDevicesWith(state: "JOINED").count > 1 )
			|| (selfDevicesWith(state: "JOINED").filter({$0.url == DeviceService.sharedInstance.deviceUrl}).isEmpty)
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
    
    var isIncomingCall: Bool {
        return fullState?.state == "ACTIVE" && myself?.alertType?.action == "FULL"
    }
    
    // TODO: only valid in one-on-one call
    var remoteVideoMuted: Bool {
        let p = remoteParticipantants[0]
        if p.state == ParticipantState.Joined && p.status?.videoStatus == "RECVONLY" {
            return true
        }
        
        return false
    }
    
    var remoteAudioMuted: Bool {
        let p = remoteParticipantants[0]
        if p.state == ParticipantState.Joined && p.status?.audioStatus == "RECVONLY" {
            return true
        }
        
        return false
    }

    // MARK: utils functions
    func participantsContain(emailDomain: String) -> Bool {
        return allParticipantants.filter({
            guard let email = $0.person?.email else {
                return false
            }
            return email.lowercased().hasSuffix(emailDomain.lowercased())
        }).count > 0
    }
    
    func allParticipantantsWith(type: String) -> [Participant] {
        return allParticipantants.filter({$0.type == type})
    }
    
    func selfDevicesWith(state: String) -> [ParticipantDevice] {
        return selfDevices.filter({$0.state == state})
    }
    
    init?(_ map: Map){
    }
    
    mutating func mapping(_ map: Map) {
        callUrl <- map["url"]
        participants <- map["participants"]
        myself <- map["self"]
        host <- map["host"]
        fullState <- map["fullState"]
        sequence <- map["sequence"]
    }
}
