//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct MediaInfo: Mappable {
    var sdp: String?
    var audioMuted: Bool?
    var videoMuted: Bool?
    var csis: [UInt]?
    var type: String? = "SDP"

    init(sdp: String, audioMuted: Bool, videoMuted: Bool) {
        self.sdp = sdp
        self.audioMuted = audioMuted
        self.videoMuted = videoMuted
    }
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        sdp <- map["sdp"]
        audioMuted <- map["audioMuted"]
        videoMuted <- map["videoMuted"]
        csis <- map["csis"]
        type <- map["type"]
    }
}