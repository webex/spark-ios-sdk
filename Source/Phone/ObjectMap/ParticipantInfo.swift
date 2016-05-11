//
//  ParticipantInfo.swift
//  Pods
//
//  Created by bxu3 on 3/21/16.
//
//

import Foundation
import ObjectMapper

public struct ParticipantInfo: Mappable {
    public var id: String?
    public var email: String?
    public var name: String?
    
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        name <- map["name"]
    }
}
