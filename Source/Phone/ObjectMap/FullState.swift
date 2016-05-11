//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct FullState: Mappable {
    var active: Bool?
    var count: Int?
    var locked: Bool?
    var lastActive: String?
    var state: String?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        active <- map["active"]
        count <- map["count"]
        locked <- map["locked"]
        lastActive <- map["lastActive"]
        state <- map["state"]
    }
}