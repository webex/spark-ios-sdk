//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

public struct RenderView {
    var local: MediaRenderView
    var remote: MediaRenderView
    
    public init(local: MediaRenderView, remote: MediaRenderView) {
        self.local = local
        self.remote = remote
    }
}