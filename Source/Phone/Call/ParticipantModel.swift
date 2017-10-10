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

struct ParticipantModel {
    
    struct DeviceModel {
        var url: String?
        var deviceType: String?
        var featureToggles: String?
        var mediaConnections: [MediaConnectionModel]?
        var state: String?
        var callLegId: String?
    }
    
    struct StatusModel {
        var audioStatus: String?
        var videoStatus: String?
        var csis: [UInt]?
    }
    
    var isCreator: Bool?
    var id: String?
    var url: String?
    var state: CallMembership.State?
    var type: String?
    var person: PersonModel?
    var status: ParticipantModel.StatusModel?
    var deviceUrl: String?
    var mediaBaseUrl: String?
    var guest: Bool?
    var alertHint: AlertHintModel?
    var alertType: AlertTypeModel?
    var enableDTMF: Bool?
    var devices: [ParticipantModel.DeviceModel]?

    var isJoined: Bool {
        return self.state == CallMembership.State.joined
    }
    
    var isDeclined: Bool {
        return self.state == CallMembership.State.declined
    }
    
    var isLeft: Bool {
        return self.state == CallMembership.State.left
    }

    func isLefted(device url: URL) -> Bool{
        return isLeft || self.devices?.filter{ $0.url == url.absoluteString }.count == 0
    }
    
    func isJoined(by: URL) -> Bool {
        return isJoined && self[device: by]?.state == "JOINED"
    }
    
    func isDeclined(by: URL) -> Bool {
        return isDeclined && self.deviceUrl == by.absoluteString
    }
    
    subscript(device url: URL) -> ParticipantModel.DeviceModel? {
        return self.devices?.filter{ $0.url == url.absoluteString }.first
    }
    
}

struct PersonModel {
    var id: String?
    var email: String?
    var name: String?
    var sipUrl: String?
    var phoneNumber: String?
    var orgId: String?
}

struct AlertHintModel {
    var action: String?
    var expiration: String?
}

struct AlertTypeModel {
    var action: String?
}


extension ParticipantModel: Mappable {
    
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        isCreator <- map["isCreator"]
        id <- map["id"]
        url <- map["url"]
        state <- (map["state"], ParticipantStateTransform())
        type <- map["type"]
        person <- map["person"]
        devices <- map["devices"]
        status <- map["status"]
        deviceUrl <- map["deviceUrl"]
        mediaBaseUrl <- map["mediaBaseUrl"]
        guest <- map["guest"]
        alertHint <- map["alertHint"]
        alertType <- map["alertType"]
        enableDTMF <- map["enableDTMF"]
    }
    
    class ParticipantStateTransform: TransformType {
        
        func transformFromJSON(_ value: Any?) -> CallMembership.State? {
            guard let state = value as? String else {
                return nil
            }
            return CallMembership.State(rawValue: state.lowercased())
        }
        
        func transformToJSON(_ value: CallMembership.State?) -> String? {
            guard let state = value else {
                return nil
            }
            return state.rawValue
        }
    }
    
}

extension ParticipantModel.DeviceModel: Mappable {
    
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        url <- map["url"]
        deviceType <- map["deviceType"]
        featureToggles <- map["featureToggles"]
        mediaConnections <- map["mediaConnections"]
        state <- map["state"]
        callLegId <- map["callLegId"]
    }
}

extension ParticipantModel.StatusModel: Mappable {
    
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        audioStatus <- map["audioStatus"]
        videoStatus <- map["videoStatus"]
        csis <- map["csis"]
    }
}

extension PersonModel: Mappable {
    
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        name <- map["name"]
        sipUrl <- map["sipUrl"]
        phoneNumber <- map["phoneNumber"]
        orgId <- map["orgId"]
    }
}

extension AlertHintModel: Mappable {
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        action <- map["action"]
        expiration <- map["expiration"]
    }
}

extension AlertTypeModel: Mappable {
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        action <- map["action"]
    }
}
