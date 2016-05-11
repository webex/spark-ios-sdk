//
//  MediaInfo.swift
//  Pods
//
//  Created by bxu3 on 3/21/16.
//
//

import Foundation
import ObjectMapper

public struct MediaInfo: Mappable {
    public var sdp: String?
    public var audioMuted: Bool?
    public var videoMuted: Bool?
    public var csis: [UInt]?
    public var type: String? = "SDP"
    
    
    public init(sdp: String, audioMuted: Bool, videoMuted: Bool) {
        self.sdp = sdp
        self.audioMuted = audioMuted
        self.videoMuted = videoMuted
    }
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
        sdp <- map["sdp"]
        audioMuted <- map["audioMuted"]
        videoMuted <- map["videoMuted"]
        csis <- map["csis"]
        type <- map["type"]
    }
}