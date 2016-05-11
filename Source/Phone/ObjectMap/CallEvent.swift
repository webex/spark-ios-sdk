//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct CallEvent : Mappable {
    var id: String?
    var callUrl: String?
    var callInfo: CallInfo?
    var type: String?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        callUrl <- map["locusUrl"]
        callInfo <- map["locus"]
        type <- map["eventType"]
    }
}