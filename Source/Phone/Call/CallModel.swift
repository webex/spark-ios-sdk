// Copyright 2016-2017 Cisco Systems Inc
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

struct CallEventModel {
    fileprivate(set) var id: String?
    fileprivate(set) var callUrl: String?
    fileprivate(set) var callModel: CallModel?
    fileprivate(set) var type: String?
}

struct FullStateModel {
    fileprivate(set) var active: Bool?
    fileprivate(set) var count: Int?
    fileprivate(set) var locked: Bool?
    fileprivate(set) var lastActive: String?
    fileprivate(set) var state: String?
}

struct ReplaceModel  {
    fileprivate(set) var locusUrl: String?
}

struct CallModel {
    fileprivate(set) var locusUrl: String? // Mandatory
    fileprivate(set) var participants: [ParticipantModel]?
    fileprivate(set) var myself: ParticipantModel?
    fileprivate(set) var host: PersonModel?
    fileprivate(set) var fullState: FullStateModel?
    fileprivate(set) var sequence: SequenceModel? // Mandatory
    fileprivate(set) var replaces: [ReplaceModel]?
    
    subscript(participant id: String) -> ParticipantModel? {
        return self.participants?.filter({$0.id == id}).first
    }
    
    var isValid: Bool {
        if let _ = self.callUrl, let _ = self.myself, let _ = self.host {
            return true
        }
        return false
    }
    
    var callUrl: String? {
        return self.replaces?.first?.locusUrl ?? self.locusUrl
    }
    
    var myselfId: String? {
        return self.myself?.id
    }
    
    var isOneOnOne: Bool {
        return participants?.filter({$0.type == "USER"}).count == 2
    }
    
    var isIncomingCall: Bool {
        return fullState?.state == "ACTIVE" && myself?.alertType?.action == "FULL"
    }
    
    var isRemoteVideoMuted: Bool {
        for participant in self.participants ?? [] where participant.id != myself?.id && participant.state == CallMembership.State.joined {
            if participant.status?.videoStatus != "RECVONLY" && participant.status?.videoStatus != "INACTIVE" {
                return false
            }
        }
        return true
    }
    
    var isRemoteAudioMuted: Bool {
        for participant in self.participants ?? [] where participant.id != myself?.id && participant.state == CallMembership.State.joined {
            if participant.status?.audioStatus != "RECVONLY" && participant.status?.audioStatus != "INACTIVE" {
                return false
            }
        }
        return true
    }
    
    var isLocalSupportDTMF: Bool {
        return self.myself?.enableDTMF ?? false
    }
}

extension CallEventModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        callUrl <- map["locusUrl"]
        callModel <- map["locus"]
        type <- map["eventType"]
    }
}

extension CallModel: Mappable {
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

extension FullStateModel: Mappable {
    init?(map: Map){ }
    
    mutating func mapping(map: Map) {
        active <- map["active"]
        count <- map["count"]
        locked <- map["locked"]
        lastActive <- map["lastActive"]
        state <- map["state"]
    }
}

extension ReplaceModel: Mappable {
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        locusUrl <- map["locusUrl"]
    }
}
