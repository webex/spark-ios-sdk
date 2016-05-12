//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct Participant: Mappable {
    var isCreator: Bool?
    var id: String?
    var url: String?
    var state: ParticipantState?
    var type: String?
    var person: ParticipantInfo?
    var devices: [ParticipantDevice]?
    var status: ParticipantStatus?
    var deviceUrl: String?
    var mediaBaseUrl: String?
    var guest: Bool?
    var alertHint: AlertHint?
    var alertType: AlertType?
    
    init?(_ map: Map){
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
    }
    
    class ParticipantStateTransform: TransformType {
        typealias Object = ParticipantState
        typealias JSON = String
        
        func transformFromJSON(value: AnyObject?) -> Object? {
            guard let state = value as? String else {
                return nil
            }
            
            switch state {
            case "UNKNOWN":
                return ParticipantState.Unknown
            case "IDLE":
                return ParticipantState.Idle
            case "NOTIFIED":
                return ParticipantState.Notified
            case "JOINED":
                return ParticipantState.Joined
            case "LEFT":
                return ParticipantState.Left
            case "DECLINED":
                return ParticipantState.Declined
            default:
                return ParticipantState.Unknown
            }
        }

        func transformToJSON(value: Object?) -> JSON? {
            return nil
        }
    }

    
}
