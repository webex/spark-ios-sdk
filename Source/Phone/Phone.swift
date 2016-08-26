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

import AVFoundation

/// Represents a Spark phone device.
open class Phone {
    
    /// Privacy control of media access type.
    public enum MediaAccessType {
        /// Access to microphone.
        case audio
        /// Access to camera.
        case video
        /// Access to both microphone and camera.
        case audioVideo
    }
    
    static let sharedInstance = Phone()

    /// Default loud speaker mode, used as the default when dialing or answering a call.
    /// True as using loud speaker, False as not.
    ///
    /// - note: The setting is not persistent.
    open var defaultFacingMode = Call.FacingMode.User
    
    /// Default camera facing mode, used as the default when dialing or answering a call.
    ///
    /// - note: The setting is not persistent
    open var defaultLoudSpeaker = true

    fileprivate let deviceService    = DeviceService.sharedInstance
    fileprivate let webSocketService = WebSocketService.sharedInstance
    fileprivate let reachabilityService = ReachabilityService.sharedInstance
    fileprivate let applicationLifecycleObserver = ApplicationLifecycleObserver.sharedInstance
    
    /// Registers the user’s device to Spark. Subsequent invocations of this method should perform a device refresh.
    ///
    /// - parameter completionHandler: A closure to be executed once the registration is completed. True means success, and False means failure.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    open func register(_ completionHandler: ((Bool) -> Void)?) {
        guard AuthManager.sharedInstance.authorized() else {
            Logger.error("Skip registering device due to no authorization")
            return
        }
        
        deviceService.registerDevice() { success in
            if success {
                self.applicationLifecycleObserver.startObserving()
                CallManager.sharedInstance.fetchActiveCalls()
                self.webSocketService.connect(URL(string: self.deviceService.webSocketUrl!)!)
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
    /// - note: This function is expected to run on main thread.
    open func deregister(_ completionHandler: ((Bool) -> Void)?) {
        reachabilityService.clear()
        applicationLifecycleObserver.stopObserving()
        webSocketService.disconnect()
        deviceService.deregisterDevice() { success in
            if success {
                completionHandler?(true)
            } else {
                completionHandler?(false)
            }
        }
    }
    
    /// Makes a call to intended recipient.
    ///
    /// - parameter address: Intended recipient address. Supported URIs: Spark URI (e.g. spark:shenning@cisco.com), SIP / SIPS URI (e.g. sip:1234@care.acme.com), Tropo URI (e.g. tropo:999123456). Supported shorthand: Email address (e.g. shenning@cisco.com), App username (e.g. jp)
    /// - parameter option: Media option for call: audio-only, audio+video etc. If it contains video, need to specify render view for video.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, and False means failure.
    /// - returns: Call object
    /// - note: This function is expected to run on main thread.
    open func dial(_ address: String, option: MediaOption, completionHandler: @escaping (Bool) -> Void) -> Call {
        let call = Call()
        call.dial(address, option: option) { success in
            if success {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        return call
    }
    
    /// Requests the end user approve the H.264 codec license from Cisco Systems.
    ///
    /// - returns: Void
    /// - note: Invoking the function is optional since the license activation alert will appear automatically during the first video call.
    open func requestVideoCodecActivation() {
        VideoLicense.sharedInstance.checkActivation() { isActivated in
            if isActivated {
                Logger.info("Video license has been activated")
            } else {
                Logger.warn("Video license has not been activated")
            }
        }
    }
    
    /// Prevents the SDK from checking H.264 video codec license activation.
    ///
    /// - returns: Void
    /// - note: The function is expected to be called only by Cisco application. 3rd-party application should NOT call this API.
    open func disableVideoCodecActivation() {
        VideoLicense.sharedInstance.disableActivation()
    }
    
    /// Requests access for media (audio and video), user can change the settings in iOS device settings.
    ///
    /// - parameter type: Request access to different media types.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means access granted, and False means not.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    open func requestMediaAccess(_ type: MediaAccessType, completionHandler: ((Bool) -> Void)?) {
        switch (type) {
        case .audio:
            requestMediaAccess(AVMediaTypeAudio) {
                completionHandler?($0)
            }
        case .video:
            requestMediaAccess(AVMediaTypeVideo) {
                completionHandler?($0)
            }
        case .audioVideo:
            requestMediaAccess(AVMediaTypeAudio) {
                if !$0 {
                    completionHandler?(false)
                } else {
                    self.requestMediaAccess(AVMediaTypeVideo) {
                        completionHandler?($0)
                    }
                }
            }
        }
    }
    
    fileprivate func requestMediaAccess(_ mediaType: String, completionHandler: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(forMediaType: mediaType) {
            let granted = $0
            DispatchQueue.main.async {
                completionHandler?(granted)
            }
        }
    }
}
