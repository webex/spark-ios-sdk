//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct ParticipantDevice: Mappable {
    var url: String?
    var deviceType: String?
    var featureToggles: String?
    var mediaConnections: [MediaConnection]?
    var state: String?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        url <- map["url"]
        deviceType <- map["deviceType"]
        featureToggles <- map["featureToggles"]
        mediaConnections <- map["mediaConnections"]
        state <- map["state"]
    }
}