// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import AVFoundation

/// Represents a Spark phone device.
public class Phone {
    
    /// Privacy control of media access type.
    public enum MediaAccessType {
        /// Access to microphone.
        case Audio
        /// Access to camera.
        case Video
        /// Access to both microphone and camera.
        case AudioVideo
    }
    
    static let sharedInstance = Phone()

    /// Default loud speaker mode, used as the default when dialing or answering a call.
    /// True as using loud speaker, False as not.
    ///
    /// - note: The setting is not persistent.
    public var defaultFacingMode = Call.FacingMode.User
    
    /// Default camera facing mode, used as the default when dialing or answering a call.
    ///
    /// - note: The setting is not persistent
    public var defaultLoudSpeaker = true

    private let deviceService    = DeviceService.sharedInstance
    private let webSocketService = WebSocketService.sharedInstance
    private let reachabilityService = ReachabilityService.sharedInstance
    private let applicationLifecycleObserver = ApplicationLifecycleObserver.sharedInstance
    
    /// Registers the user’s device to Spark. Subsequent invocations of this method should perform a device refresh.
    ///
    /// - parameter completionHandler: A closure to be executed once the registration is completed. True means success, and False means failure.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    public func register(completionHandler: (Bool -> Void)?) {
        guard AuthManager.sharedInstance.authorized() else {
            Logger.error("Skip registering device due to no authorization")
            return
        }
        
        deviceService.registerDevice() { success in
            if success {
                self.applicationLifecycleObserver.startObserving()
                CallManager.sharedInstance.fetchActiveCalls()
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
    /// - note: This function is expected to run on main thread.
    public func deregister(completionHandler: (Bool -> Void)?) {
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
    public func dial(address: String, option: MediaOption, completionHandler: (Bool) -> Void) -> Call {
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
    public func requestVideoCodecActivation() {
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
    public func disableVideoCodecActivation() {
        VideoLicense.sharedInstance.disableActivation()
    }
    
    /// Requests access for media (audio and video), user can change the settings in iOS device settings.
    ///
    /// - parameter type: Request access to different media types.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means access granted, and False means not.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    public func requestMediaAccess(type: MediaAccessType, completionHandler: (Bool -> Void)?) {
        switch (type) {
        case .Audio:
            requestMediaAccess(AVMediaTypeAudio) {
                completionHandler?($0)
            }
        case .Video:
            requestMediaAccess(AVMediaTypeVideo) {
                completionHandler?($0)
            }
        case .AudioVideo:
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
    
    private func requestMediaAccess(mediaType: String, completionHandler: (Bool -> Void)?) {
        AVCaptureDevice.requestAccessForMediaType(mediaType) {
            let granted = $0
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(granted)
            }
        }
    }
}
