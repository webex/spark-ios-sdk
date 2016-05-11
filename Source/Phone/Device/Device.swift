//
//  Device.swift
//  Pods
//
//  Created by bxu3 on 3/14/16.
//
//

import Foundation
import ObjectMapper

struct Device: Mappable {
    var deviceUrl: String?
    var webSocketUrl: String?
    var services: [String: String]?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        deviceUrl <- map["url"]
        webSocketUrl <- map["webSocketUrl"]
        services <- map["services"]
    }
}
