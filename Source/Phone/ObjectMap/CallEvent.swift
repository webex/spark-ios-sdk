//
//  CallEvent.swift
//  Pods
//
//  Created by bxu3 on 3/29/16.
//
//

import Foundation
import ObjectMapper

public struct CallEvent: Mappable {
    public var id: String?
    public var callUrl: String?
    public var callInfo: CallInfo?
    public var type: String?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        callUrl <- map["locusUrl"]
        callInfo <- map["locus"]
        type <- map["eventType"]
    }
}