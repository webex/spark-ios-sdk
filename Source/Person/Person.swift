//
//  Person.swift
//  SparkSDK
//
//  Created by xiuwenwu on 16/2/22.
//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Person: Mappable {
    public var id: String?
    public var emails: [String]?
    public var displayName: String?
    public var avatar: String?
    public var created: String?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        emails <- map["emails"]
        displayName <- map["displayName"]
        avatar <- map["avatar"]
        created <- map["created"]
    }
}