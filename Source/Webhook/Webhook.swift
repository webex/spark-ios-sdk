//
//  Webhook.swift
//  Pods
//
//  Created by bxu3 on 3/3/16.
//
//

import Foundation
import ObjectMapper

public struct Webhook: Mappable {
    public var id: String?
    public var name: String?
    public var targetUrl: String?
    public var resource: String?
    public var event: String?
    public var filter: String?
    public var created: NSTimeInterval?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        targetUrl <- map["targetUrl"]
        resource <- map["resource"]
        event <- map["event"]
        name <- map["name"]
        filter <- map["filter"]
        created <- map["created"]
    }
}