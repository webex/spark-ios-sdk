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

struct MediaInfo: Mappable {
    var sdp: String?
    var audioMuted: Bool?
    var videoMuted: Bool?
    var csis: [UInt]?
    var reachabilities: [String /* media cluster tag */ : Reachability]?
    var type: String? = "SDP"

    init(sdp: String, audioMuted: Bool, videoMuted: Bool, reachabilities: [String: Reachability]?) {
        self.sdp = sdp
        self.audioMuted = audioMuted
        self.videoMuted = videoMuted
        self.reachabilities = reachabilities
    }
    
    init?(map: Map){
    }
    
    mutating func mapping(map: Map) {
        sdp <- map["sdp"]
        audioMuted <- map["audioMuted"]
        videoMuted <- map["videoMuted"]
        csis <- map["csis"]
        reachabilities <- map["reachability"]
        type <- map["type"]
    }
}
