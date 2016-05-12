//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import AVFoundation

public class Phone {
    public typealias CompletionHandler = Bool -> Void
    
    static let sharedInstance = Phone()
    
    public var defaultFacingMode: String {
        get {
            if let facingMode = UserDefaults.sharedInstance.facingMode {
                return facingMode
            }
            return Call.FacingMode.User.rawValue
        }
        set {
            UserDefaults.sharedInstance.facingMode = newValue
        }
    }
    
    public var defaultLoudSpeaker: Bool {
        get {
            if let loudSpeaker = UserDefaults.sharedInstance.loudSpeaker {
                return loudSpeaker
            }
            return true
        }
        set {
            UserDefaults.sharedInstance.loudSpeaker = newValue
        }
    }
    
    private let deviceService    = DeviceService.sharedInstance
    private let webSocketService = WebSocketService.sharedInstance
    
    public func register(completionHandler: (Bool -> Void)?) {
        CallManager.sharedInstance.startObserving()
        
        deviceService.registerDevice() { success in
            if success {
                // TODO: need to check if it's ok when register again.
                // TODO: need to consider reconnect case.
                self.webSocketService.connect(NSURL(string: self.deviceService.webSocketUrl!)!)
                completionHandler?(true)
            } else {
                completionHandler?(false)
            }
        }
    }
    
    public func deregister(completionHandler: CompletionHandler?) {
        CallManager.sharedInstance.stopObserving()
        
        deviceService.deregisterDevice() { success in
            if success {
                self.webSocketService.disconnect()
                completionHandler?(true)
            } else {
                completionHandler?(false)
            }
        }
    }
    
    public func dial(address: String, renderView: RenderView, completionHandler: (Call?) -> Void) {
        let call = Call()
        call.dial(address, renderView: renderView) { success in
            if success {
                completionHandler(call)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    public func requestAccessForMedia(completionHandler: ((Bool) -> Void)!) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { grantedAccessToCamera in
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio) { grantedAccessToMicrophone in
                if grantedAccessToCamera && grantedAccessToMicrophone {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(true)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(false)
                    }
                }
            }
        }
    }
}
