//
//  AlertType.swift
//  Pods
//
//  Created by niliu2 on 5/9/16.
//
//

import Foundation
import ObjectMapper


public struct AlertType: Mappable {
    public var action: String?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        action <- map["action"]
    }
}
