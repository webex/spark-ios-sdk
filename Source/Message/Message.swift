//
//  Message.swift
//  Pods
//
//  Created by Bin Xu on 3/1/16.
//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Message: Mappable {
    public var id: String?
    public var personId: String?
    public var personEmail: String?
    public var roomId: String?
    public var text: String?
    public var files: [String]?
    public var toPersonId: String?
    public var toPersonEmail: String?
    public var created: NSTimeInterval?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        personId <- map["personId"]
        personEmail <- map["personEmail"]
        roomId <- map["roomId"]
        text <- map["text"]
        files <- map["files"]
        toPersonId <- map["toPersonId"]
        toPersonEmail <- map["toPersonEmail"]
        created <- map["files"]
    }
}