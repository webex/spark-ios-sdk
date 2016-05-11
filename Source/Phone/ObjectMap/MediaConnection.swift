//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

struct MediaConnection: Mappable {
    var mediaId: String?

    var type: String?
    var localSdp: MediaInfo?
    var remoteSdp: MediaInfo?
    var actionsUrl: String?
    var keepAliveUrl: String?
    var keepAliveSecs: Int?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        mediaId <- map["mediaId"]
        type <- map["type"]
        localSdp <- (map["localSdp"], MediaTransform())
        remoteSdp <- (map["remoteSdp"], MediaTransform())
        actionsUrl <- map["actionsUrl"]
        keepAliveUrl <- map["keepAliveUrl"]
        keepAliveSecs <- map["keepAliveSecs"]

    }
    
    class MediaTransform: TransformType {
        typealias Object = MediaInfo
        typealias JSON = String
        
        func transformFromJSON(value: AnyObject?) -> Object?{
            let mediaInfo = Mapper<MediaInfo>().map(value as? String)
            return mediaInfo
            
        }
        func transformToJSON(value: Object?) -> JSON? {
            return nil
        }
    }
}
