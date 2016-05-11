//
//  Membership.swift
//  Pods
//
//  Created by Bin Xu on 3/1/16.
//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public struct Membership: Mappable {
    public var id: String?
    public var personId: String?
    public var personEmail: String?
    public var roomId: String?
    public var isModerator: Bool?
    public var isMonitor: Bool?
    public var created: String?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        personId <- map["personId"]
        personEmail <- map["personEmail"]
        roomId <- map["roomId"]
        isModerator <- map["isModerator"]
        isMonitor <- map["isMonitor"]
        created <- map["created"]
    }
}
