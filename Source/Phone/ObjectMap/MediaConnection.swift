//
//  Device.swift
//  Pods
//
//  Created by bxu3 on 3/14/16.
//
//

import Foundation
import ObjectMapper

public struct MediaConnection: Mappable {
    public var mediaId: String?

    public var type: String?
    public var localSdp: MediaInfo?
    public var remoteSdp: MediaInfo?
    public var actionsUrl: String?
    public var keepAliveUrl: String?
    public var keepAliveSecs: Int?
    
    public init?(_ map: Map){
    }
    
    public mutating func mapping(map: Map) {
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
