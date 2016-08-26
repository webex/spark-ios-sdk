// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
    
    mutating func mapping(_ map: Map) {
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
        
        func transformFromJSON(_ value: Any?) -> Object? {
            let mediaInfo = Mapper<MediaInfo>().map(value as? String)
            return mediaInfo
            
        }
        func transformToJSON(_ value: Object?) -> JSON? {
            return nil
        }
    }
}
