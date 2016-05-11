//
//  File.swift
//  Pods
//
//  Created by bxu3 on 3/21/16.
//
//

import Foundation
import ObjectMapper


public struct ParticipantDevice: Mappable {
    public var url: String?
    public var deviceType: String?
    public var featureToggles: String?
    public var mediaConnections: [MediaConnection]?
    public var state: String?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        url <- map["url"]
        deviceType <- map["deviceType"]
        featureToggles <- map["featureToggles"]
        mediaConnections <- map["mediaConnections"]
        state <- map["state"]
    }
}