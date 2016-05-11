//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct ParticipantInfo: Mappable {
    var id: String?
    var email: String?
    var name: String?

    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        name <- map["name"]
    }
}
