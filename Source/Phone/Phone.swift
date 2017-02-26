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

import AVFoundation

/// Phone represents a Cisco Spark calling device.
/// The application can obtain the *phone* object from *Spark* object 
/// and use *phone* to call other Cisco Spark users or PSTN when enabled.
/// The *phone* must be registered before it can make or receive calls.
///
/// ```` swift
///     spark.phone.register() { success in
///       if success {
///         ... // Successfully registered device
///       } else {
///         ...    // Device was not registered, and no calls can be sent or received
///       }
///     }
/// ````
/// - since: 1.2.0
public class Phone {
    
    /// The enumeration of media access type for privacy control.
    public enum MediaAccessType {
        /// Access to microphone (audio).
        case audio
        /// Access to camera (video).
        case video
        /// Access to both microphone and camera.
        case audioVideo
    }
    
    private let authenticationStrategy: AuthenticationStrategy
    private let applicationLifecycleObserver: ApplicationLifecycleObserver
    private let webSocketService: WebSocketService
    private let callManager: CallManager
    private let deviceService: DeviceService
    
    init(authenticationStrategy: AuthenticationStrategy, applicationLifecycleObserver: ApplicationLifecycleObserver, webSocketService: WebSocketService, callManager: CallManager, deviceService: DeviceService) {
        self.authenticationStrategy = authenticationStrategy
        self.applicationLifecycleObserver = applicationLifecycleObserver
        self.webSocketService = webSocketService
        self.callManager = callManager
        self.deviceService = deviceService
        webSocketService.deviceReregistrationStrategy = self
    }
    
    /// This function registers this *phone* to Cisco Spark cloud on behave of the authenticated user.
    /// It also creates the websocket and connects to Cisco Spark cloud.
    /// Subsequent invocations of this method refresh the registration.
    ///
    /// - parameter completionHandler: A closure to be executed once the registration is completed. True means success, and False means failure.
    /// - returns: Void
    /// - since: 1.2.0
    public func register(_ completionHandler: ((Bool) -> Void)?) {
        // XXX This guard means that the completion handler may never be fired
        guard authenticationStrategy.authorized else {
            Logger.error("Skip registering device due to no authorization")
            return
        }
        
        deviceService.registerDevice() { deviceRegistrationInformation in
            if let deviceRegistrationInformation = deviceRegistrationInformation {
                self.applicationLifecycleObserver.startObserving()
                self.callManager.fetchActiveCalls()
                self.webSocketService.connect(deviceRegistrationInformation.webSocketUrl)
            }
            completionHandler?(deviceRegistrationInformation != nil)
        }
    }
    
    /// This function removes this *phone* from Cisco Spark cloud on behave of the authenticated user.
    /// It also disconnects the websocket from Cisco Spark cloud.
    /// Subsequent invocations of this method behave as a no-op.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, and False means failure.
    /// - returns: Void
    /// - since: 1.2.0
    public func deregister(_ completionHandler: ((Bool) -> Void)?) {
        callManager.clearReachabilityState()
        applicationLifecycleObserver.stopObserving()
        webSocketService.disconnect()
        deviceService.deregisterDevice() { success in
            completionHandler?(success)
        }
    }
    
    /// This function makes a call to an intended recipient on behalf of the authenticated user.
    /// It supports the following address formats for the receipient:
    ///
    /// >
    ///  * Spark URI: e.g. spark:shenning@cisco.com
    ///  * SIP / SIPS URI: e.g. sip:1234@care.acme.com
    ///  * Tropo URI: e.g. tropo:999123456
    ///  * Email address: e.g. shenning@cisco.com
    ///  * App username: e.g. jp
    /// >
    ///
    /// - parameter address: Intended recipient address in one of the supported formats.
    /// - parameter option: Intended media options - audio only or audio and video - for the call.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, and False means failure.
    /// - returns: a Call object
    /// - throw:
    /// - since: 1.2.0
    /// - attention: Currently the SDK only supports one active call at a time. Invoking this function while there is an active call will generate an exception.
   public func dial(_ address: String, option: MediaOption, completionHandler: @escaping (Bool) -> Void) -> Call {
        let call = callManager.createOutgoingCall()
        call.dial(address: address, option: option) { success in
            completionHandler(success)
        }
        return call
    }
    
    /// This function pops up an Alert for the end user to approve the use of H.264 codec license from Cisco Systems, Inc.
    ///
    /// - returns: Void
    /// - note: Invoking this function is optional since the alert will appear automatically during the first video call.
    /// - since: 1.2.0
    public func requestVideoCodecActivation() {
        callManager.requestVideoCodecActivation()
    }
    
    /// This function prevents Cisco Spark iOS SDK from poping up an Alert for the end user
    /// to approve the use of H.264 video codec license from Cisco Systems, Inc.
    ///
    /// - returns: Void
    /// - attention: The function is expected to be called only by Cisco internal applications. 3rd-party applications should NOT call this function.
    /// - since: 1.2.0
    public func disableVideoCodecActivation() {
        callManager.disableVideoCodecActivation()
    }
    
    /// This function requests access for media (audio and video) on the user's iOS device. 
    /// The user can change the settings in iOS device settings.
    ///
    /// - parameter type: Request access to different media types.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means access granted, and False means not.
    /// - returns: Void
    /// - since: 1.2.0
    public func requestMediaAccess(_ type: MediaAccessType, completionHandler: ((Bool) -> Void)?) {
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
    
    private func requestMediaAccess(_ mediaType: String, completionHandler: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(forMediaType: mediaType) {
            let granted = $0
            DispatchQueue.main.async {
                completionHandler?(granted)
            }
        }
    }
}

extension Phone: DeviceReregistrationStrategy {
    func reregisterDevice() {
        register(nil)
    }
}
