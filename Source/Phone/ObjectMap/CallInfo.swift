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

struct CallInfo {
    var locusUrl: String? // Mandatory
    var participants: [Participant]?
    var myself: Participant?
    var host: ParticipantInfo?
    var fullState: FullState?
    var sequence: Sequence? // Mandatory
    var replaces: [Replace]?
    
    var selfEmail: String? {
        return myself?.person?.email
    }
    
    var hostEmail: String? {
        return host?.email
    }
   
    var selfDevices: [ParticipantDevice] {
        guard let devices = myself?.devices else {
            return []
        }
        return devices
    }
    
    var callUrl : String? {
        if let replace = self.replaces?.first {
            return replace.locusUrl
        }
        return locusUrl
    }
    
    private var allParticipantants: [Participant] {
        guard let allParticipants = participants else {
            return []
        }
        
        return allParticipants
    }

    private var selfParticipantant: Participant? {
        return myself
    }
    
    var remoteParticipantants: [Participant] {
        return allParticipantants.filter({$0.id != myself?.id})
    }
    
    var selfMediaUrl: String? {
        return myself?.mediaBaseUrl
    }
    
    var enableDTMF: Bool? {
        return selfParticipantant?.enableDTMF
    }
    
    var lastActive: String? {
        return fullState?.lastActive
    }
    
    var isOneOnOne: Bool {
        return allParticipantants.filter({$0.type == "USER"}).count == 2
    }
    
    var hasJoined: Bool {
        return myself?.state == ParticipantState.Joined
    }

    func hasJoinedOnThisDevice(deviceUrl: URL) -> Bool {
        return hasJoined && !selfDevicesWith(state: "JOINED").filter({$0.url == deviceUrl.absoluteString}).isEmpty
    }

    func hasJoinedOnOtherDevice(deviceUrl: URL) -> Bool {
        return hasJoined && !selfDevicesWith(state: "JOINED").filter({$0.url != deviceUrl.absoluteString}).isEmpty
    }
    
    private func selfDevicesWith(state: String) -> [ParticipantDevice] {
        return selfDevices.filter({$0.state == state})
    }

    var hasLeft: Bool {
        return selfParticipantant?.state == ParticipantState.Left
    }

    func hasDeclined(deviceUrl: URL) -> Bool {
        if selfParticipantant?.state != ParticipantState.Declined {
            return false
        }
        return selfParticipantant?.deviceUrl == deviceUrl.absoluteString
    }

    func hasDeclinedOnOtherDevice(deviceUrl: URL) -> Bool {
        if selfParticipantant?.state != ParticipantState.Declined {
            return false
        }
        return selfParticipantant?.deviceUrl != deviceUrl.absoluteString
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
}

extension CallInfo: Mappable {
	init?(map: Map) { }
	
	mutating func mapping(map: Map) {
		locusUrl <- map["url"]
		participants <- map["participants"]
		myself <- map["self"]
		host <- map["host"]
		fullState <- map["fullState"]
		sequence <- map["sequence"]
        replaces <- map["replaces"]
	}
}

struct Replace: Mappable {
    var locusUrl: String?
    
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        locusUrl <- map["locusUrl"]
    }
}
