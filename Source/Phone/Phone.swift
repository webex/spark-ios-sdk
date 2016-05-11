//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import AVFoundation

public class Phone {
    
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
    
    public func register(completionHandler: (Bool -> Void)? = nil) {
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
    
    public func deregister(completionHandler: (Bool -> Void)? = nil) {
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
    
    public func dial(address: String, completionHandler: ((Call?) -> Void)!) {
        requestAccessForMedia() { granted in
            if granted {
                let call = Call()
                call.dial(address)
                completionHandler(call)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Camera, Speaker, Microphone
    
    public func requestAccessForMedia(completionHandler: ((Bool) -> Void)!) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { grantedAccessToCamera in
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio) { grantedAccessToMicrophone in
                if grantedAccessToCamera && grantedAccessToMicrophone {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(true)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Phone.CameraMicrophoneAccessDenied, object: nil)
                        completionHandler(false)
                    }
                }
            }
        }
    }
}
