//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper


struct ParticipantStatus: Mappable {
    var audioStatus: String?
    var videoStatus: String?
    var csis: [UInt]?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        audioStatus <- map["audioStatus"]
        videoStatus <- map["videoStatus"]
        csis <- map["csis"]
    }
}