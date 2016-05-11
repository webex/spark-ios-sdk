//
//  ParticipantStatus.swift
//  Pods
//
//  Created by bxu3 on 3/21/16.
//
//

import Foundation
import ObjectMapper


public struct ParticipantStatus: Mappable {
    public var audioStatus: String?
    public var videoStatus: String?
    public var csis: [UInt]?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        audioStatus <- map["audioStatus"]
        videoStatus <- map["videoStatus"]
        csis <- map["csis"]
    }
}