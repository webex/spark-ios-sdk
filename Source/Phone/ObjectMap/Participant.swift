//
//  Participant.swift
//  Pods
//
//  Created by bxu3 on 3/21/16.
//
//

import Foundation
import ObjectMapper

public struct Participant: Mappable {
    public var isCreator: Bool?
    public var id: String?
    public var url: String?
    public var state: ParticipantState?
    public var type: String?
    public var person: ParticipantInfo?
    public var devices: [ParticipantDevice]?
    public var status: ParticipantStatus?
    public var deviceUrl: String?
    public var mediaBaseUrl: String?
    public var guest: Bool?
    public var alertHint: AlertHint?
    public var alertType: AlertType?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
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
        
        func transformFromJSON(value: AnyObject?) -> Object?{
            
            let state = value as? String
            if state == nil {
                return nil
            }
            
            switch state! {
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
