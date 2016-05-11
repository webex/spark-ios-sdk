//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct AlertHint: Mappable {
    var action: String?
    var expiration: String?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        action <- map["action"]
        expiration <- map["expiration"]
    }
}