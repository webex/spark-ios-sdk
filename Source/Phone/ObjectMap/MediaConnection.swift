// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
