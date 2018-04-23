// Copyright 2016-2018 Cisco Systems Inc
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

struct MediaShareModel {
    
    public enum MediaShareType : String {
        /// The share floor is screen-sharing .
        case screen
        /// The share floor is whiteboard-sharing.
        case whiteboard
        /// The floor is unknown type.
        case unknown
    }
    
    public enum ShareFloorDisposition : String {
        /// The share floor status is created.
        case granted
        /// The share floor status is released.
        case released
        /// The floor disposition status is unknown.
        case unknown
    }
    
    struct MediaShareFloor {
        var beneficiary: ParticipantModel?
        var disposition: ShareFloorDisposition?
        var granted: String?
        var released: String?
        var requested: String?
        var requester: ParticipantModel?
    }
    
    var shareType: MediaShareType?
    var url: String?
    var shareFloor: MediaShareFloor?
}


extension MediaShareModel: Mappable {
    
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        shareType <- (map["name"], ShareTypeTransform())
        url <- map["url"]
        shareFloor <- map["floor"]
    }
    
    class ShareTypeTransform: TransformType {
        
        func transformFromJSON(_ value: Any?) -> MediaShareModel.MediaShareType? {
            guard let type = value as? String else {
                return nil
            }
            return type == "content" ? MediaShareModel.MediaShareType.screen : MediaShareModel.MediaShareType(rawValue: type.lowercased())
        }
        
        func transformToJSON(_ value: MediaShareModel.MediaShareType?) -> String? {
            guard let type = value else {
                return nil
            }
            return type.rawValue == "screen" ? "content":type.rawValue
        }
    }
    
    
}

extension MediaShareModel.MediaShareFloor: Mappable {
    
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        beneficiary <- map["beneficiary"]
        disposition <- (map["disposition"], DispositionTypeTransform())
        granted <- map["granted"]
        released <- map["released"]
        requested <- map["requested"]
        requester <- map["requester"]
    }
    
    class DispositionTypeTransform: TransformType {
        
        func transformFromJSON(_ value: Any?) -> MediaShareModel.ShareFloorDisposition? {
            guard let disposition = value as? String else {
                return nil
            }
            
            if disposition.lowercased() != "granted" && disposition.lowercased() != "released" {
                return MediaShareModel.ShareFloorDisposition.unknown
            }
            
            return MediaShareModel.ShareFloorDisposition(rawValue: disposition.lowercased())
        }
        
        func transformToJSON(_ value: MediaShareModel.ShareFloorDisposition?) -> String? {
            guard let type = value else {
                return nil
            }
            return type.rawValue
        }
    }
}


