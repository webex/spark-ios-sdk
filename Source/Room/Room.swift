//
//  Room.swift
//  Pods
//
//  Created by bxu3 on 2/25/16.
//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public struct Room: Mappable {
    public var id: String?
    public var title: String?
    public var type: String?
    public var isLocked: Bool?
    public var sipAddress: String?
    public var lastActivity: String?
    public var created: String?
    
    
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        type <- map["type"]
        isLocked <- map["isLocked"]
        sipAddress <- map["sipAddress"]
        lastActivity <- map["lastActivity"]
        created <- map["created"]
    }
}