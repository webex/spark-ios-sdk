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
    
    /// The enumeration of Camera facing modes.
    public enum FacingMode {
        /// Front camera.
        case user
        /// Back camera.
        case environment
    }
    
    /// Default camera facing mode, used as the default when dialing or answering a call.
    ///
    /// - note: The setting is not persistent
    public var defaultFacingMode = FacingMode.user
    
    /// Default loud speaker mode, used as the default when dialing or answering a call.
    /// True as using loud speaker, False as not.
    ///
    /// - note: The setting is not persistent.
    public var defaultLoudSpeaker: Bool = true
    
    /// Callback when call is incoming.
    public var onIncoming: ((Call) -> Void)?
    
    let authenticator: Authenticator
    let reachability: ReachabilityService
    let metrics: CallMetrics
    let client: CallClient
    let prompter: H264LicensePrompter
    let queue = SerialQueue()
    
    private let devices: DeviceService    
    private let webSocket: WebSocketService
    private var calls = [String: Call]()
    private var mediaContext: MediaSessionWrapper?
    
    enum LocusResult {
        case call(Device, UUID?, MediaSessionWrapper, ServiceResponse<CallModel>, (Result<Call>) -> Void)
        case join(Call, ServiceResponse<CallModel>)
        case leave(Call, ServiceResponse<CallModel>)
        case reject(Call, ServiceResponse<Any>)
        case update(Call, ServiceResponse<CallModel>)
    }
    
    init(authenticator: Authenticator) {
        let _ = MediaEngineWrapper.sharedInstance.WMEVersion
        self.authenticator = authenticator
        self.devices = DeviceService(authenticator: authenticator)
        self.reachability = ReachabilityService(authenticator: authenticator, deviceService: self.devices)
        self.metrics = CallMetrics(authenticator: authenticator, deviceService: self.devices)
        self.client = CallClient(authenticator: authenticator)
        self.prompter = H264LicensePrompter(metrics: self.metrics)
        self.webSocket = WebSocketService(authenticator: authenticator)
        self.webSocket.onFailed = { [weak self] in
            self?.register {_ in
            }
        }
        self.webSocket.onCallModel = { [weak self] model in
            if let strong = self {
                strong.queue.underlying.async {
                    strong.doLocusEvent(model);
                }
            }
        }
    }
    
    deinit {
        self.metrics.deinitMetrics()
    }
    
    /// This function registers this *phone* to Cisco Spark cloud on behave of the authenticated user.
    /// It also creates the websocket and connects to Cisco Spark cloud.
    /// Subsequent invocations of this method refresh the registration.
    ///
    /// - parameter completionHandler: A closure to be executed once the registration is completed. True means success, and False means failure.
    /// - returns: Void
    /// - since: 1.2.0
    public func register(_ completionHandler: @escaping ((Error?) -> Void)) {
        self.queue.sync {
            self.devices.registerDevice(phone: self, queue: self.queue.underlying) { result in
                switch result {
                case .success(let device):
                    self.webSocket.connect(device.webSocketUrl) { [weak self] error in
                        if let error = error {
                            SDKLogger.error("Failed to Register device", error: error)
                        }
                        self?.queue.underlying.async {
                            self?.fetchActiveCalls()
                            DispatchQueue.main.async {
                                self?.reachability.fetch()
                                self?.startObserving()
                                completionHandler(error)
                            }
                            self?.queue.yield()
                        }
                    }
                case .failure(let error):
                    SDKLogger.error("Failed to Register device", error: error)
                    DispatchQueue.main.async {
                        completionHandler(error)
                    }
                    self.queue.yield()
                }
            }
        }
    }
    
    /// This function removes this *phone* from Cisco Spark cloud on behave of the authenticated user.
    /// It also disconnects the websocket from Cisco Spark cloud.
    /// Subsequent invocations of this method behave as a no-op.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, and False means failure.
    /// - returns: Void
    /// - since: 1.2.0
    public func deregister(_ completionHandler: @escaping ((Error?) -> Void)) {
        self.queue.sync {
            self.devices.deregisterDevice(queue: self.queue.underlying) { error in
                self.webSocket.disconnect()
                DispatchQueue.main.async {
                    self.reachability.clear()
                    self.stopObserving()
                    completionHandler(error)
                }
                self.queue.yield()
            }
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
    public func dial(_ address: String, option: MediaOption, completionHandler: @escaping ((Result<Call>) -> Void)) {
        prepare(option: option) { error in
            if let error = error {
                completionHandler(Result.failure(error))
            }
            else {
                let mediaContext = self.mediaContext ?? MediaSessionWrapper()
                mediaContext.prepare(option: option, phone: self)
                let localSDP = mediaContext.getLocalSdp()
                let reachabilities = self.reachability.feedback?.reachabilities
                self.queue.sync {
                    if let device = self.devices.device {
                        let media = MediaModel(sdp: localSDP, audioMuted: false, videoMuted: false, reachabilities: reachabilities)
                        self.client.create(address, by: device, localMedia: media, queue: self.queue.underlying) { res in
                            if let error = res.result.error {
                                if error is SparkErrors {
                                    switch error as! SparkErrors {
                                    case .notFound(let target):
                                        if let email = EmailAddress.fromString(target) {
                                            Spark(authenticator: self.authenticator).people.list(email: email, displayName: nil, max: 1) { persons in
                                                if let id = persons.result.data?.first?.id {
                                                    self.client.create(id, by: device, localMedia: media, queue: self.queue.underlying) { resNew in
                                                        self.doLocusResponse(LocusResult.call(device, option.uuid, mediaContext, resNew, completionHandler))
                                                        self.queue.yield()
                                                    }
                                                }
                                                else {
                                                    self.doLocusResponse(LocusResult.call(device, option.uuid, mediaContext, res, completionHandler))
                                                    self.queue.yield()
                                                }
                                            }
                                            return;
                                        }
                                    default: break
                                    }
                                }
                            }
                            self.doLocusResponse(LocusResult.call(device, option.uuid, mediaContext, res, completionHandler))
                            self.queue.yield()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            completionHandler(Result.failure(SparkErrors.unregistered))
                        }
                        self.queue.yield()
                    }
                }
            }
        }
    }
    
    /// This function pops up an Alert for the end user to approve the use of H.264 codec license from Cisco Systems, Inc.
    ///
    /// - returns: Void
    /// - note: Invoking this function is optional since the alert will appear automatically during the first video call.
    /// - since: 1.2.0
    public func requestVideoCodecActivation() {
        self.prompter.check() { _ in }
    }
    
    /// This function prevents Cisco Spark iOS SDK from poping up an Alert for the end user
    /// to approve the use of H.264 video codec license from Cisco Systems, Inc.
    ///
    /// - returns: Void
    /// - attention: The function is expected to be called only by Cisco internal applications. 3rd-party applications should NOT call this function.
    /// - since: 1.2.0
    public func disableVideoCodecActivation() {
        self.prompter.disable = true
    }
    
    public func startPreview(option: MediaOption) {
        DispatchQueue.main.async {
            self.mediaContext = MediaSessionWrapper()
            self.mediaContext.startPreview(option: option)
        }
    }
    
    public func stopPreview() {
        DispatchQueue.main.async {
            if let media = self.mediaContext {
                media.stopPreview()
            }
        }
    }
    
    private func add(call: Call) {
        calls[call.url] = call;
        SDKLogger.info("Add call for call url:\(call.url)")
    }
    
    func remove(call: Call) {
        calls[call.url] = nil
        SDKLogger.info("Remove call for call url:\(call.url)")
    }
    
    func answer(call: Call, option: MediaOption) {
        DispatchQueue.main.async {
            let mediaContext = call.mediaSession
            mediaContext.prepare(option: option, phone: self)
            let media = MediaModel(sdp: mediaContext.getLocalSdp(), audioMuted: false, videoMuted: false, reachabilities: self.reachability.feedback?.reachabilities)
            self.queue.sync {
                self.client.join(call.url, by: call.device, localMedia: media, queue: self.queue.underlying) { res in
                    self.doLocusResponse(LocusResult.join(call, res))
                    self.queue.yield()
                }
            }
        }
    }
    
    func reject(call: Call) {
        self.queue.sync {
            guard let url = call.model.callUrl else {
                SDKLogger.error("Failure: Missing call URL")
                DispatchQueue.main.async {
                    call.onError?(Call.Error.reject(SparkErrors.missingAttributes))
                }
                self.queue.yield()
                return
            }
            DispatchQueue.main.async {
                call.stopMedia()
            }
            self.client.decline(url, by: call.device, queue: self.queue.underlying) { res in
                self.doLocusResponse(LocusResult.reject(call, res))
                self.queue.yield()
            }
        }
    }
    
    func hangup(call: Call) {
        self.queue.sync {
            guard let url = call.model.myself?.url else {
                SDKLogger.error("Failure: Missing self participant URL")
                DispatchQueue.main.async {
                    call.onError?(Call.Error.hangup(SparkErrors.missingAttributes))
                }
                self.queue.yield()
                return
            }
            DispatchQueue.main.async {
                call.stopMedia()
            }
            self.client.leave(url, by: call.device, queue: self.queue.underlying) { res in
                self.doLocusResponse(LocusResult.leave(call, res))
                self.queue.yield()
            }
        }
    }
    
    func update(call: Call, sendingAudio: Bool, sendingVideo: Bool) {
        DispatchQueue.main.async {
            let reachabilities = self.reachability.feedback?.reachabilities
            self.queue.sync {
                guard let url = call.model.myself?.mediaBaseUrl, let sdp = call.model.myself?[device: call.device.deviceUrl]?.mediaConnections?.first?.localSdp?.sdp else {
                    self.queue.yield()
                    return
                }
                let media = MediaModel(sdp: sdp, audioMuted: !sendingAudio, videoMuted: !sendingVideo, reachabilities: reachabilities)
                self.client.update(url, by: call.device, localMedia: media, queue: self.queue.underlying) { res in
                    self.doLocusResponse(LocusResult.update(call, res))
                    self.queue.yield()
                }
            }
        }
    }
    
    func fetch(call: Call) {
        self.queue.sync {
            self.client.fetch(call.url, queue: self.queue.underlying) { res in
                self.doLocusResponse(LocusResult.update(call, res))
                self.queue.yield()
            }
        }
    }
    
    private func doLocusResponse(_ ret: LocusResult) {
        switch ret {
        case .call(let device, let uuid, let media, let res, let completionHandler):
            switch res.result {
            case .success(let model):
                if model.isValid {
                    let call = Call(model: model, device: device, media: media, direction: Call.Direction.outgoing, uuid: uuid)
                    self.add(call: call)
                    DispatchQueue.main.async {
                        call.startMedia()
                        completionHandler(Result.success(call))
                    }
                }
                else {
                    completionHandler(Result.failure(SparkErrors.missingAttributes))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(Result.failure(error))
                }
            }
        case .join(let call, let res):
            switch res.result {
            case .success(let model):
                SDKLogger.info("Success: join call")
                call.doCallModel(model)
                DispatchQueue.main.async {
                    call.startMedia()
                }
            case .failure(let error):
                SDKLogger.error("Failure", error: error)
                DispatchQueue.main.async {
                    call.onError?(Call.Error.answer(error))
                }
            }
        case .leave(let call, let res):
            switch res.result {
            case .success(let model):
                SDKLogger.info("Success: leave call")
                call.doCallModel(model)
            case .failure(let error):
                SDKLogger.error("Failure", error: error)
                DispatchQueue.main.async {
                    call.onError?(Call.Error.answer(error))
                }
            }
        case .reject(let call, let res):
            switch res.result {
            case .success(_):
                SDKLogger.info("Success: reject call")
                call.device.phone.remove(call: call)
                call.status = .disconnected
                DispatchQueue.main.async {
                    call.onDisconnected?(Call.DisconnectType.localDecline)
                }
            case .failure(let error):
                SDKLogger.error("Failure", error: error)
                DispatchQueue.main.async {
                    call.onError?(Call.Error.answer(error))
                }
            }
        case .update(let call, let res):
            switch res.result {
            case .success(let model):
                SDKLogger.info("Success: update media")
                call.doCallModel(model)
            case .failure(let error):
                SDKLogger.error("Failure", error: error)
            }
        }
        
    }
    
    private func doLocusEvent(_ model: CallModel) {
        guard let url = model.callUrl else {
            SDKLogger.error("CallInfo is missing call url")
            return
        }
        if let call = self.calls[url] {
            call.doCallModel(model)
        }
        else if let device = self.devices.device, model.isIncomingCall { // || callInfo.hasJoinedOnOtherDevice(deviceUrl: deviceUrl)
            // XXX: Is this conditional intended to add this call even when there is no real device registration information?
            // At the time of writing the deviceService.deviceUrl will return a saved value from the UserDefaults. When the application
            // has been restarted and the reregistration process has not completed, other critical information such as locusServiceUrl
            // will not be available, but the deviceUrl WILL be. This may put the application in a bad state. This code MAY be dealing with
            // a race condition and this MAY be the solution to not dropping a call before reregistration has been completed.
            // If so it needs improvement, if not it may be able to be dropped.
            if model.isValid {
                let call = Call(model: model, device: device, media: self.mediaContext ?? MediaSessionWrapper(), direction: Call.Direction.incoming, uuid: nil)
                SDKLogger.info("Receive incoming call: \(call)")
                DispatchQueue.main.async {
                    self.onIncoming?(call)
                }
            }
            else {
                SDKLogger.info("Receive incoming call with error: \(model)")
            }
            // TODO: need to support other device joined case
        }
    }
    
    private func prepare(option: MediaOption, completionHandler: @escaping (Error?) -> Void) {
        if option.hasVideo {
            self.prompter.check() { activated in
                if activated {
                    completionHandler(nil)
                }
                else {
                    completionHandler(SparkErrors.h264Required)
                }
            }
        }
        else {
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }

    private func fetchActiveCalls() {
        SDKLogger.info("Fetch call infos")
        if let device = self.devices.device {
            self.client.fetch(by: device, queue: self.queue.underlying) { res in
                switch res.result {
                case .success(let models):
                    for model in models {
                        self.doLocusEvent(model)
                    }
                    SDKLogger.info("Success: fetch call infos")
                case .failure(let error):
                    SDKLogger.error("Failure", error: error)
                }
            }
        }
    }
    
    private func startObserving() {
        self.stopObserving();
        NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationDidBecomeActive) , name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationDidEnterBackground) , name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    private func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func onApplicationDidBecomeActive() {
        SDKLogger.info("Application did become active")
        if let device = self.devices.device {
            self.webSocket.connect(device.webSocketUrl) { [weak self] error in
                if let error = error {
                    SDKLogger.error("Failed to Register device", error: error)
                }
                self?.queue.underlying.async {
                    self?.fetchActiveCalls()
                }
            }
        }
    }
    
    @objc func onApplicationDidEnterBackground() {
        SDKLogger.info("Application did enter background")
        self.webSocket.disconnect();
    }
}
