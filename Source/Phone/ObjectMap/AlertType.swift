//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct AlertType: Mappable {
    var action: String?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        action <- map["action"]
    }
}
