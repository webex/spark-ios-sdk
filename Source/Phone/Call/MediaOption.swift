// Copyright 2016-2017 Cisco Systems Inc
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

/// A data type represents the media options of a *call*.
///
/// - since: 1.2.0
public struct MediaOption {
    
    /// Constructs an audio only media option.
    ///
    /// - since: 1.2.0
    public static func audioOnly() -> MediaOption {
        return MediaOption()
    }
    
    /// Constructs an audio and video media option with video render views.
    ///
    /// - since: 1.2.0
    public static func audioVideo(local: MediaRenderView, remote: MediaRenderView) -> MediaOption {
        return MediaOption(local: local, remote: remote,hasVideo:true)
    }
    
    /// Constructs an audio and video media option with optional render views.
    /// The render views can be set after call is connected.
    ///
    /// - since: 1.3.0
    public static func audioVideo(renderViews:(local:MediaRenderView,remote:MediaRenderView)? = nil) -> MediaOption {
        return MediaOption(local: renderViews?.local, remote: renderViews?.remote,hasVideo:true)
    }
    
    /// Constructs an audio, video, and screen share media option with optional render views.
    /// The render views can be set after call is connected.
    ///
    /// - since: 1.3.0
    public static func audioVideoScreenShare(video:(local:MediaRenderView,remote:MediaRenderView)? = nil, screenShare: MediaRenderView? = nil) -> MediaOption {
        return MediaOption(local: video?.local, remote: video?.remote, screenShare: screenShare, hasVideo:true, hasScreenShare:true)
    }
    
    var localVideoView: MediaRenderView?
    
    var remoteVideoView: MediaRenderView?
    
    var screenShareView: MediaRenderView?
    
    fileprivate var _uuid: UUID?
    
    let hasVideo: Bool
    
    let hasScreenShare: Bool
    
    init() {
        self.hasVideo = false
        self.hasScreenShare = false
    }
    
    init(local: MediaRenderView? = nil, remote: MediaRenderView? = nil ,screenShare: MediaRenderView? = nil, hasVideo: Bool = false, hasScreenShare: Bool = false) {
        self.hasVideo = hasVideo
        self.hasScreenShare = hasScreenShare
        self.localVideoView = local
        self.remoteVideoView = remote
        self.screenShareView = screenShare
    }
}

// CallKit
public extension MediaOption {
    
    /// A local unique identifier of a media options.
    ///
    /// - since: 1.2.0
    public var uuid: UUID? {
        get {
            return self._uuid
        }
        set {
            self._uuid = newValue
        }
    }
    
}

