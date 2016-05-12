//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Render view collection for local and remote video.
public struct RenderView {
    var local: MediaRenderView
    var remote: MediaRenderView
    
    /// Constructor for a render view collection.
    public init(local: MediaRenderView, remote: MediaRenderView) {
        self.local = local
        self.remote = remote
    }
}