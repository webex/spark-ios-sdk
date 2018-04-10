import UIKit

// MediaRenderView is an OpenGL backed UIView
public class MediaRenderView: UIView {
    
    override public class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
}
