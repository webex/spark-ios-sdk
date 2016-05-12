//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import AVFoundation

/// Represents a Spark phone device.
public class Phone {
    
    static let sharedInstance = Phone()

    private let deviceService    = DeviceService.sharedInstance
    private let webSocketService = WebSocketService.sharedInstance
    
    /// Default camera facing mode, used as the default when dialing or answering a call.
    public var defaultFacingMode: Call.FacingMode {
        get {
            if let facingModeString = UserDefaults.sharedInstance.facingMode {
                return Call.FacingMode(rawValue: facingModeString)!
            }
            return Call.FacingMode.User
        }
        set {
            UserDefaults.sharedInstance.facingMode = newValue.rawValue
        }
    }
    
    /// Default loud speaker mode, used as the default when dialing or answering a call.
    /// True as using loud speaker, False as not.
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

    /// Registers the user’s device to Spark. Subsequent invocations of this method should perform a device refresh.
    ///
    /// - parameter completionHandler: A closure to be executed once the registration is completed. True means success, and False means failure.
    /// - returns: Void
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
    
    /// Removes the user’s device from Spark and disconnects the websocket. 
    /// Subsequent invocations of this method should behave as a no-op.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, and False means failure.
    /// - returns: Void
    public func deregister(completionHandler: (Bool -> Void)?) {
        CallManager.sharedInstance.stopObserving()
        
        // TODO: need to check if it's ok to deregister again.
        deviceService.deregisterDevice() { success in
            if success {
                self.webSocketService.disconnect()
                completionHandler?(true)
            } else {
                completionHandler?(false)
            }
        }
    }
    
    /// Makes a call to intended recipient.
    ///
    /// - parameter address: Intended recipient address. Supported URIs: Spark URI (e.g. spark:shenning@cisco.com), SIP / SIPS URI (e.g. sip:1234@care.acme.com), Tropo URI (e.g. tropo:999123456). Supported shorthand: Email address (e.g. shenning@cisco.com), App username (e.g. jp)
    /// - parameter renderView: Render view when call get connected.
    /// - parameter completionHandler: A closure to be executed once the action is completed. Non-nil means success and represents a call object, nil means failure.
    /// - returns: Void
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
    
    /// Requests access for media (audio and video), user can change the settings in iOS device settings.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means access granted, and False means not.
    /// - returns: Void
    public func requestAccessForMedia(completionHandler: (Bool -> Void)?) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { grantedAccessToCamera in
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio) { grantedAccessToMicrophone in
                if grantedAccessToCamera && grantedAccessToMicrophone {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(true)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(false)
                    }
                }
            }
        }
    }
}
