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
    
    /// Constructs an audio and video media option.
    ///
    /// - since: 1.2.0
    public static func audioVideo(local: MediaRenderView, remote: MediaRenderView) -> MediaOption {
        return MediaOption(local: local, remote: remote)
    }
    
    /// The local video view
    ///
    /// - since: 1.3.0
    var localVideoView: MediaRenderView?
    
    /// The remote video view
    ///
    /// - since: 1.3.0
    var remoteVideoView: MediaRenderView?
    
    fileprivate var _uuid: UUID?
    
    /// Whether video is enabled.
    ///
    /// - returns: False if neither local or remote video is enabled. Otherwise, true.
    /// - since: 1.3.0
    var hasVideo: Bool {
        return self.localVideoView != nil || self.remoteVideoView != nil
    }
    
    init() {
        
    }
    
    init(local: MediaRenderView, remote: MediaRenderView) {
        self.localVideoView = local
        self.remoteVideoView = remote
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
