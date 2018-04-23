// Copyright 2016-2018 Cisco Systems Inc
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
/// The application can obtain a *phone* object from *Spark* object
/// and use *phone* to call other Cisco Spark users or PSTN when enabled.
/// The *phone* must be registered before it can make or receive calls.
///
/// ```` swift
///     spark.phone.register() { error in
///       if let error = error {
///         ... // Device was not registered, and no calls can be sent or received
///       } else {
///         ... // Successfully registered device
///       }
///     }
/// ````
/// - since: 1.2.0
public class Phone {
    
    /// The enumeration of Camera facing modes.
    ///
    /// - since: 1.2.0
    public enum FacingMode {
        /// Front camera.
        case user
        /// Back camera.
        case environment
    }
    
    /// The enumeration of common bandwidth choices.
    ///
    /// - since: 1.3.0
    public enum DefaultBandwidth: UInt32 {
        // 177Kbps for 160x90 resolution
        case maxBandwidth90p = 177000
        // 384Kbps for 320x180 resolution
        case maxBandwidth180p = 384000
        // 768Kbps for 640x360 resolution
        case maxBandwidth360p = 768000
        // 2Mbps for 1280x720 resolution
        case maxBandwidth720p = 2000000
        // 3Mbps for 1920x1080 resolution
        case maxBandwidth1080p = 3000000
        // 4Mbps data session
        case maxBandwidthSession = 4000000
        // 64kbps for voice
        case maxBandwidthAudio = 64000
    }
    
    /// The max bandwidth for audio in unit bps for the call.
    /// Only effective if set before the start of call.
    /// if 0, default value of 64 * 1000 is used.
    ///
    /// - since: 1.3.0
    public var audioMaxBandwidth: UInt32 = DefaultBandwidth.maxBandwidthAudio.rawValue
    
    /// The max bandwidth for video in unit bps for the call.
    /// Only effective if set before the start of call.
    /// if 0, default value of 2000*1000 is used.
    ///
    /// - since: 1.3.0
    public var videoMaxBandwidth: UInt32 = DefaultBandwidth.maxBandwidth720p.rawValue
    
    /// The max bandwidth for screen sharing in unit bps for the call.
    /// Only effective if set before the start of call.
    /// if 0, default value of 4000*1000 is used.
    ///
    /// - since: 1.3.0
    public var screenShareMaxBandwidth: UInt32 = DefaultBandwidth.maxBandwidthSession.rawValue
    
    /// Default camera facing mode of this phone, used as the default when dialing or answering a call.
    /// The default mode is the front camera.
    ///
    /// - note: The setting is not persistent
    /// - since: 1.2.0
    public var defaultFacingMode = FacingMode.user
    
    /// Default loud speaker mode of this phone, used as the default when dialing or answering a call.
    /// True as using loud speaker, False as not. The default is using loud speaker.
    ///
    /// - note: The setting is not persistent.
    /// - since: 1.2.0
    public var defaultLoudSpeaker: Bool = true
    
    /// Callback when call is incoming.
    ///
    /// - since: 1.2.0
    public var onIncoming: ((Call) -> Void)?
    
    /// Indicates whether or not the SDK is connected with the Cisco Spark cloud.
    ///
    /// - since: 1.4.0
    public private(set) var connected: Bool = false
    
    /// Indicates whether or not the SDK is registered with the Cisco Spark cloud.
    ///
    /// - since: 1.4.0
    public var registered: Bool {
        return self.devices.device != nil
    }
    
    let authenticator: Authenticator
    let reachability: ReachabilityService
    let client: CallClient
    let conversations: ConversationClient
    let prompter: H264LicensePrompter
    let queue = SerialQueue()
    let metrics: MetricsEngine
    private(set) var messages: MessageClientImpl?
    
    private let devices: DeviceService
    private let webSocket: WebSocketService
    private var calls = [String: Call]()
    private var mediaContext: MediaSessionWrapper?
    
    var debug = true;
    
    enum LocusResult {
        case call(Bool, Device, UUID?, MediaSessionWrapper, ServiceResponse<CallModel>, (Result<Call>) -> Void)
        case join(Call, ServiceResponse<CallModel>, (Error?) -> Void)
        case leave(Call, ServiceResponse<CallModel>, (Error?) -> Void)
        case reject(Call, ServiceResponse<Any>, (Error?) -> Void)
        case alert(Call, ServiceResponse<Any>, (Error?) -> Void)
        case update(Call, ServiceResponse<CallModel>)
        case updateMediaShare(Call, ServiceResponse<Any>, (Error?) -> Void)
    }
    
    convenience init(authenticator: Authenticator) {
        let device = DeviceService(authenticator: authenticator)
        let metrics = MetricsEngine(authenticator: authenticator, service: device)
        self.init(authenticator: authenticator,
                  devices: device,
                  reachability: ReachabilityService(authenticator: authenticator, deviceService: device),
                  client: CallClient(authenticator: authenticator),
                  conversations: ConversationClient(authenticator: authenticator), metrics: metrics, prompter: H264LicensePrompter(metrics: metrics), webSocket: WebSocketService(authenticator: authenticator))
    }
    
    init(authenticator: Authenticator, devices:DeviceService, reachability:ReachabilityService, client:CallClient, conversations:ConversationClient, metrics:MetricsEngine, prompter:H264LicensePrompter, webSocket:WebSocketService) {
        let _ = MediaEngineWrapper.sharedInstance.WMEVersion
        self.authenticator = authenticator
        self.devices = devices
        self.reachability = reachability
        self.client = client
        self.conversations = conversations
        self.metrics = metrics
        self.prompter = prompter
        self.webSocket = webSocket
        self.webSocket.onEvent = { [weak self] event in
            if let strong = self {
                strong.queue.underlying.async {
                    switch event {
                    case .recvCall(let model):
                        strong.doLocusEvent(model);
                    case .recvActivity(let model):
                        strong.doConversationEvent(model);
                    case .recvKms(let model):
                        strong.doKmsEvent(model);
                    case .connected:
                        strong.connected = true
                    case .disconnected(let error):
                        strong.connected = false
                        if error != nil {
                            strong.register {_ in
                            }
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        self.metrics.release()
    }
    
    /// Registers this phone to Cisco Spark cloud on behalf of the authenticated user.
    /// It also creates the websocket and connects to Cisco Spark cloud.
    /// Subsequent invocations of this method refresh the registration.
    ///
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - since: 1.2.0
    public func register(_ completionHandler: @escaping ((Error?) -> Void)) {
        self.queue.sync {
            self.devices.registerDevice(phone: self, queue: self.queue.underlying) { result in
                switch result {
                case .success(let device):
                    if let messages = self.messages {
                        messages.deviceUrl = device.deviceUrl
                    }
                    else {
                        self.messages = MessageClientImpl(authenticator: self.authenticator, deviceUrl: device.deviceUrl)
                    }
                    self.webSocket.connect(device.webSocketUrl) { [weak self] error in
                        if let error = error {
                            SDKLogger.shared.error("Failed to Register device", error: error)
                        }
                        if let strong = self {
                            strong.queue.underlying.async {
                                strong.fetchActiveCalls()
                                DispatchQueue.main.async {
                                    strong.reachability.fetch()
                                    strong.startObserving()
                                    completionHandler(error)
                                }
                                strong.queue.yield()
                            }
                        }
                    }
                case .failure(let error):
                    SDKLogger.shared.error("Failed to Register device", error: error)
                    DispatchQueue.main.async {
                        completionHandler(error)
                    }
                    self.queue.yield()
                }
            }
        }
    }
    
    /// Removes this *phone* from Cisco Spark cloud on behalf of the authenticated user.
    /// It also disconnects the websocket from Cisco Spark cloud.
    /// Subsequent invocations of this method behave as a no-op.
    ///
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - since: 1.2.0
    public func deregister(_ completionHandler: @escaping ((Error?) -> Void)) {
        self.queue.sync {
            self.devices.deregisterDevice(queue: self.queue.underlying) { error in
                self.disconnectFromWebSocket()
                DispatchQueue.main.async {
                    self.reachability.clear()
                    self.stopObserving()
                    completionHandler(error)
                }
                self.queue.yield()
            }
        }
    }
        
    /// Makes a call to an intended recipient on behalf of the authenticated user.
    /// It supports the following address formats for the receipient:
    ///
    /// >
    ///  * Spark URI: e.g. spark:shenning@cisco.com
    ///  * SIP / SIPS URI: e.g. sip:1234@care.acme.com
    ///  * Tropo URI: e.g. tropo:999123456
    ///  * Email address: e.g. shenning@cisco.com
    /// >
    ///
    /// - parameter address: Intended recipient address in one of the supported formats.
    /// - parameter option: Intended media options - audio only or audio and video - for the call.
    /// - parameter completionHandler: A closure to be executed when completed.
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
                if self.calls.filter({!$0.value.isGroup || ($0.value.isGroup && $0.value.status == CallStatus.connected)}).count > 0 {
                    SDKLogger.shared.error("Failure: There are other active calls")
                    completionHandler(Result.failure(SparkError.illegalOperation(reason: "There are other active calls")))
                    return
                }
                self.requestMediaAccess(option: option) {
                    let mediaContext = self.mediaContext ?? MediaSessionWrapper()
                    mediaContext.prepare(option: option, phone: self)
                    let localSDP = mediaContext.getLocalSdp()
                    let reachabilities = self.reachability.feedback?.reachabilities
                    
                    CallClient.DialTarget.lookup(address, by: Spark(authenticator: self.authenticator)) { target in
                        self.queue.sync {
                            if let device = self.devices.device {
                                let media = MediaModel(sdp: localSDP, audioMuted: false, videoMuted: false, reachabilities: reachabilities)
                                if target.isEndpoint {
                                    self.client.create(target.address, by: device, localMedia: media, queue: self.queue.underlying) { res in
                                        self.doLocusResponse(LocusResult.call(target.isGroup, device, option.uuid, mediaContext, res, completionHandler))
                                        self.queue.yield()
                                    }
                                }
                                else {
                                    self.conversations.getLocusUrl(conversation: target.address, by: device, queue: self.queue.underlying) { res in
                                        if let url = res.result.data?.locusUrl {
                                            self.client.join(url, by: device, localMedia: media, queue: self.queue.underlying) { resNew in
                                                self.doLocusResponse(LocusResult.call(target.isGroup, device, option.uuid, mediaContext, resNew, completionHandler))
                                                self.queue.yield()
                                            }
                                        }
                                        else if let error = res.result.error {
                                            SDKLogger.shared.error("Failure call ", error: error)
                                            DispatchQueue.main.async {
                                                completionHandler(Result.failure(error))
                                            }
                                            self.queue.yield()
                                        }
                                    }
                                }
                            }
                            else {
                                SDKLogger.shared.error("Failure: unregistered device")
                                DispatchQueue.main.async {
                                    completionHandler(Result.failure(SparkError.unregistered))
                                }
                                self.queue.yield()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Pops up an Alert for the end user to approve the use of H.264 codec license from Cisco Systems, Inc.
    ///
    /// - returns: Void
    /// - note: Invoking this function is optional since the alert will appear automatically during the first video call.
    /// - since: 1.2.0
    public func requestVideoCodecActivation() {
        self.prompter.check() { _ in }
    }
    
    /// Prevents Cisco Spark iOS SDK from poping up an Alert for the end user
    /// to approve the use of H.264 video codec license from Cisco Systems, Inc.
    ///
    /// - returns: Void
    /// - attention: The function is expected to be called only by Cisco internal applications. 3rd-party applications should NOT call this function.
    /// - since: 1.2.0
    public func disableVideoCodecActivation() {
        self.prompter.disable = true
    }
    
    /// Render a preview of the local party before the call is answered.
    ///
    /// - parameter view: an UI view for rendering video.
    /// - returns: Void
    public func startPreview(view: MediaRenderView) {
        DispatchQueue.main.async {
            if self.mediaContext == nil {
                self.mediaContext = MediaSessionWrapper()
            }
            _ = self.mediaContext?.startPreview(view: view, phone: self)
        }
    }
    
    /// Stop rendering the preview of the local party.
    ///
    /// - returns: Void
    public func stopPreview() {
        DispatchQueue.main.async {
            if let media = self.mediaContext {
                media.stopPreview()
            }
        }
    }
    
    private func add(call: Call) {
        calls[call.url] = call;
        SDKLogger.shared.info("Add call for call url:\(call.url)")
    }
    
    func remove(call: Call) {
        calls[call.url] = nil
        SDKLogger.shared.info("Remove call for call url:\(call.url)")
    }
    
    func acknowledge(call: Call, completionHandler: @escaping (Error?) -> Void) {
        self.queue.sync {
            if self.calls.filter({ $0.key != call.url }).count > 0 {
                SDKLogger.shared.error("Failure: There are other active calls")
                DispatchQueue.main.async {
                    completionHandler(SparkError.illegalOperation(reason: "There are other active calls"))
                }
                self.queue.yield()
                return
            }
            if call.direction == Call.Direction.outgoing {
                SDKLogger.shared.error("Failure: Unsupport function for outgoing call")
                DispatchQueue.main.async {
                    completionHandler(SparkError.illegalOperation(reason: "Unsupport function for outgoing call"))
                }
                self.queue.yield()
                return
            }
            if call.direction == Call.Direction.incoming && call.status != CallStatus.initiated {
                SDKLogger.shared.error("Failure: Not initialted call")
                DispatchQueue.main.async {
                    completionHandler(SparkError.illegalStatus(reason: "Not initialted call"))
                }
                self.queue.yield()
                return
            }
            if let url = call.model.locusUrl {
                self.client.alert(url, by: call.device, queue: self.queue.underlying) { res in
                    self.doLocusResponse(LocusResult.alert(call, res, completionHandler))
                    self.queue.yield()
                }
            }
            else {
                SDKLogger.shared.error("Failure: Missing call URL")
                DispatchQueue.main.async {
                    completionHandler(SparkError.serviceFailed(code: -7000, reason: "Missing call URL"))
                }
                self.queue.yield()
            }
        }
    }
    
    func answer(call: Call, option: MediaOption, completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            if self.calls.filter({ $0.key != call.url && $0.value.status == CallStatus.connected}).count > 0 {
                SDKLogger.shared.error("Failure: There are other active calls")
                completionHandler(SparkError.illegalOperation(reason: "There are other active calls"))
                return
            }
            if call.direction == Call.Direction.outgoing {
                SDKLogger.shared.error("Failure: Unsupport function for outgoing call")
                completionHandler(SparkError.illegalOperation(reason: "Unsupport function for outgoing call"))
                return
            }
            if call.direction == Call.Direction.incoming {
                if call.status == CallStatus.connected {
                    SDKLogger.shared.error("Failure: Already connected")
                    completionHandler(SparkError.illegalStatus(reason: "Already connected"))
                    return
                }
                else if call.status == CallStatus.disconnected {
                    SDKLogger.shared.error("Failure: Already disconnected")
                    completionHandler(SparkError.illegalStatus(reason: "Already disconnected"))
                    return
                }
            }
            if let uuid = option.uuid {
                call._uuid = uuid
            }
            
            self.requestMediaAccess(option: option) {
                let mediaContext = call.mediaSession
                mediaContext.prepare(option: option, phone: self)
                let media = MediaModel(sdp: mediaContext.getLocalSdp(), audioMuted: false, videoMuted: false, reachabilities: self.reachability.feedback?.reachabilities)
                self.queue.sync {
                    self.client.join(call.url, by: call.device, localMedia: media, queue: self.queue.underlying) { res in
                        self.doLocusResponse(LocusResult.join(call, res, completionHandler))
                        self.queue.yield()
                    }
                }
            }
        }
    }
    
    func reject(call: Call, completionHandler: @escaping (Error?) -> Void) {
        self.queue.sync {
            if call.direction == Call.Direction.outgoing {
                SDKLogger.shared.error("Failure: Unsupport function for outgoing call")
                DispatchQueue.main.async {
                    completionHandler(SparkError.illegalOperation(reason: "Unsupport function for outgoing call"))
                }
                self.queue.yield()
                return
            }
            if call.direction == Call.Direction.incoming {
                if call.status == CallStatus.connected {
                    SDKLogger.shared.error("Failure: Already connected")
                    DispatchQueue.main.async {
                        completionHandler(SparkError.illegalStatus(reason: "Already connected"))
                    }
                    self.queue.yield()
                    return
                }
                else if call.status == CallStatus.disconnected {
                    SDKLogger.shared.error("Failure: Already disconnected")
                    DispatchQueue.main.async {
                        completionHandler(SparkError.illegalStatus(reason: "Already disconnected"))
                    }
                    self.queue.yield()
                    return
                }
            }
            if let url = call.model.locusUrl {
                self.client.decline(url, by: call.device, queue: self.queue.underlying) { res in
                    self.doLocusResponse(LocusResult.reject(call, res, completionHandler))
                    self.queue.yield()
                }
            }
            else {
                SDKLogger.shared.error("Failure: Missing call URL")
                DispatchQueue.main.async {
                    completionHandler(SparkError.serviceFailed(code: -7000, reason: "Missing call URL"))
                }
                self.queue.yield()
            }
        }
    }
    
    func hangup(call: Call, completionHandler: @escaping (Error?) -> Void) {
        self.queue.sync {
            if call.status == CallStatus.disconnected {
                SDKLogger.shared.warn("Warning: Already disconnected")
                DispatchQueue.main.async {
                    completionHandler(SparkError.illegalStatus(reason: "Already disconnected"))
                }
                self.queue.yield()
                return
            }
            if let url = call.model.myself?.url {
                if #available(iOS 11.2, *), call.sendingScreenShare {
                    self.stopSharing(call: call) {
                        _ in
                        SDKLogger.shared.warn("Unshare screen by call end!")
                    }
                    call.mediaSession.stopLocalScreenShare()
                }
                
                
                self.client.leave(url, by: call.device, queue: self.queue.underlying) { res in
                    self.doLocusResponse(LocusResult.leave(call, res, completionHandler))
                    self.queue.yield()
                }
            }
            else {
                SDKLogger.shared.error("Failure: Missing self participant URL")
                DispatchQueue.main.async {
                    completionHandler(SparkError.serviceFailed(code: -7000, reason: "Missing self participant URL"))
                }
                self.queue.yield()
            }
        }
    }
    
    func update(call: Call, sendingAudio: Bool, sendingVideo: Bool, localSDP:String? = nil) {
        DispatchQueue.main.async {
            let reachabilities = self.reachability.feedback?.reachabilities
            self.queue.sync {
                guard let url = call.model.myself?.mediaBaseUrl, let sdp = call.model.myself?[device: call.device.deviceUrl]?.mediaConnections?.first?.localSdp?.sdp, let mediaID = call.model.myself?[device: call.device.deviceUrl]?.mediaConnections?.first?.mediaId else {
                    self.queue.yield()
                    return
                }
                let media = MediaModel(sdp: localSDP == nil ? sdp:localSDP!, audioMuted: !sendingAudio, videoMuted: !sendingVideo, reachabilities: reachabilities)
                self.client.update(url,by: mediaID,by: call.device, localMedia: media, queue: self.queue.underlying) { res in
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
    
    @available(iOS 11.2,*)
    func startSharing(call:Call, completionHandler: @escaping ((Error?) -> Void)) {
        if !call.mediaSession.hasScreenShare {
            let error = SparkError.illegalOperation(reason: "Call media option unsupport content share.")
            completionHandler(error)
            SDKLogger.shared.error("Failure", error: error)
            return
        }
        
        if call.isScreenSharedBySelfDevice() {
            let error = SparkError.illegalStatus(reason: "Already shared by self.")
            completionHandler(error)
            SDKLogger.shared.error("Failure", error: error)
            return
        }
        
        if call.status != .connected {
            let error = SparkError.illegalStatus(reason: "No active call.")
            completionHandler(error)
            SDKLogger.shared.error("Failure", error: error)
            return
        }
        
        let floor : MediaShareModel.MediaShareFloor = MediaShareModel.MediaShareFloor(beneficiary: call.model.myself, disposition: MediaShareModel.ShareFloorDisposition.granted, granted: nil, released: nil, requested: nil, requester: call.model.myself)
        
        let mediaShare : MediaShareModel = MediaShareModel(shareType: MediaShareModel.MediaShareType.screen, url:call.model.mediaShareUrl, shareFloor: floor)
        self.updateMeidaShare(call: call, mediaShare: mediaShare, completionHandler: completionHandler)

    }
    
    @available(iOS 11.2,*)
    func stopSharing(call:Call, completionHandler: @escaping ((Error?) -> Void)) {
        if !call.mediaSession.hasScreenShare {
            let error = SparkError.illegalOperation(reason: "Call media option unsupport content share.")
            completionHandler(error)
            SDKLogger.shared.error("Failure", error: error)
            return
        }
        
        if !call.isScreenSharedBySelfDevice() {
            let error = SparkError.illegalStatus(reason: "Local share screen not start.")
            completionHandler(error)
            SDKLogger.shared.error("Failure", error: error)
            return
        }
        
        let floor : MediaShareModel.MediaShareFloor = MediaShareModel.MediaShareFloor(beneficiary: call.model.myself, disposition: MediaShareModel.ShareFloorDisposition.released, granted: nil, released: nil, requested: nil, requester: call.model.myself)
        
        let mediaShare : MediaShareModel = MediaShareModel(shareType: MediaShareModel.MediaShareType.screen, url:call.model.mediaShareUrl, shareFloor: floor)
        self.updateMeidaShare(call: call, mediaShare: mediaShare, completionHandler: completionHandler)
    }
    
    private func doLocusResponse(_ ret: LocusResult) {
        switch ret {
        case .call(let group, let device, let uuid, let media, let res, let completionHandler):
            switch res.result {
            case .success(let model):
                SDKLogger.shared.debug("Receive call locus response: \(model.toJSONString(prettyPrint: self.debug) ?? "Nil JSON")")
                if model.isValid {
                    let call = Call(model: model, device: device, media: media, direction: Call.Direction.outgoing, group: (group ? true : !model.isOneOnOne), uuid: uuid)
                    if call.isInIllegalStatus {
                        DispatchQueue.main.async {
                            let error = SparkError.illegalStatus(reason: "The previous session did not end")
                            SDKLogger.shared.error("Failure call ", error: error)
                            completionHandler(Result.failure(error))
                            call.end(reason: Call.DisconnectReason.error(error))
                        }
                        return
                    }
                    self.add(call: call)
                    DispatchQueue.main.async {
                        call.startMedia()
                        completionHandler(Result.success(call))
                    }
                }
                else {
                    completionHandler(Result.failure(SparkError.serviceFailed(code: -7000, reason: "Failure: Missing required information when dial")))
                }
            case .failure(let error):
                SDKLogger.shared.error("Failure call ", error: error)
                DispatchQueue.main.async {
                    completionHandler(Result.failure(error))
                }
            }
        case .join(let call, let res, let completionHandler):
            switch res.result {
            case .success(let model):
                SDKLogger.shared.debug("Receive join locus response: \(model.toJSONString(prettyPrint: self.debug) ?? "Nil JSON")")
                call.update(model: model)
                DispatchQueue.main.async {
                    call.startMedia()
                    completionHandler(nil)
                }
            case .failure(let error):
                SDKLogger.shared.error("Failure join ", error: error)
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        case .leave(let call, let res, let completionHandler):
            switch res.result {
            case .success(let model):
                SDKLogger.shared.debug("Receive leave locus response: \(model.toJSONString(prettyPrint: self.debug) ?? "Nil JSON")")
                call.update(model: model)
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            case .failure(let error):
                SDKLogger.shared.error("Failure leave ", error: error)
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        case .reject(let call, let res, let completionHandler):
            switch res.result {
            case .success(_):
                SDKLogger.shared.info("Success: reject call")
                call.end(reason: Call.DisconnectReason.localDecline)
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            case .failure(let error):
                SDKLogger.shared.error("Failure reject ", error: error)
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        case .alert(let call, let res, let completionHandler):
            switch res.result {
            case .success(_):
                SDKLogger.shared.info("Success: alert call")
                call.status = .ringing
                DispatchQueue.main.async {
                    call.onRinging?()
                    completionHandler(nil)
                }
            case .failure(let error):
                SDKLogger.shared.error("Failure alert ", error: error)
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        case .update(let call, let res):
            switch res.result {
            case .success(let model):
                SDKLogger.shared.debug("Receive update media locus response: \(model.toJSONString(prettyPrint: self.debug) ?? "Nil JSON")")
                call.update(model: model)
            case .failure(let error):
                SDKLogger.shared.error("Failure update media ", error: error)
            }
        case .updateMediaShare( _, let res, let completionHandler):
            switch res.result {
            case .success(let json):
                SDKLogger.shared.debug("Receive update media share locus response: \(json)")
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            case .failure(let error):
                SDKLogger.shared.error("Failure update media share", error: error)
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        }
        
    }
    
    private func doLocusEvent(_ model: CallModel) {
        SDKLogger.shared.debug("Receive locus event: \(model.toJSONString(prettyPrint: self.debug) ?? "Nil JSON")")
        guard let url = model.callUrl else {
            SDKLogger.shared.error("CallModel is missing call url")
            return
        }
        if let call = self.calls[url] {
            call.update(model: model)
        }
        else if let device = self.devices.device, model.isIncomingCall { // || callInfo.hasJoinedOnOtherDevice(deviceUrl: deviceUrl)
            // XXX: Is this conditional intended to add this call even when there is no real device registration information?
            // At the time of writing the deviceService.deviceUrl will return a saved value from the UserDefaults. When the application
            // has been restarted and the reregistration process has not completed, other critical information such as locusServiceUrl
            // will not be available, but the deviceUrl WILL be. This may put the application in a bad state. This code MAY be dealing with
            // a race condition and this MAY be the solution to not dropping a call before reregistration has been completed.
            // If so it needs improvement, if not it may be able to be dropped.
            if model.isValid {
                let call = Call(model: model, device: device, media: self.mediaContext ?? MediaSessionWrapper(), direction: Call.Direction.incoming, group: !model.isOneOnOne, uuid: nil)
                self.add(call: call)
                SDKLogger.shared.info("Receive incoming call: \(call.model.callUrl ?? call._uuid.uuidString)")
                DispatchQueue.main.async {
                    self.onIncoming?(call)
                }
            }
            else {
                SDKLogger.shared.info("Receive incoming call with error: \(model)")
            }
            // TODO: need to support other device joined case
        }
        else {
            SDKLogger.shared.info("Cannot handle the CallModel.")
        }
    }
    
    private func doConversationEvent(_ model: ActivityModel){
        if let messages = self.messages {
            SDKLogger.shared.debug("Receive Conversation Acitivity: \(model.toJSONString(prettyPrint: self.debug) ?? "Nil JSON")")
            messages.handle(activity: model)
        }
    }
    
    private func doKmsEvent( _ model: KmsMessageModel){
        if let messages = self.messages{
            SDKLogger.shared.debug("Receive Kms Message: \(model.toJSONString(prettyPrint: self.debug) ?? "Nil JSON")")
            messages.handle(kms: model)
        }
    }
    
    private func prepare(option: MediaOption, completionHandler: @escaping (Error?) -> Void) {
        if option.hasVideo {
            self.prompter.check() { activated in
                if activated {
                    completionHandler(nil)
                }
                else {
                    completionHandler(SparkError.requireH264)
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
        SDKLogger.shared.info("Fetch call infos")
        if let device = self.devices.device {
            self.client.fetch(by: device, queue: self.queue.underlying) { res in
                switch res.result {
                case .success(let models):
                    for model in models {
                        self.doLocusEvent(model)
                    }
                    SDKLogger.shared.info("Success: fetch call infos")
                case .failure(let error):
                    SDKLogger.shared.error("Failure", error: error)
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
        SDKLogger.shared.info("Application did become active")
        self.connectToWebSocket()
    }
    
    @objc func onApplicationDidEnterBackground() {
        SDKLogger.shared.info("Application did enter background")
        self.disconnectFromWebSocket()
    }
    
    private func connectToWebSocket() {
        if let device = self.devices.device {
            self.webSocket.connect(device.webSocketUrl) { [weak self] error in
                if let error = error {
                    SDKLogger.shared.error("Failed to Register device", error: error)
                }
                self?.queue.underlying.async {
                    self?.fetchActiveCalls()
                }
            }
        }
    }
    
    private func disconnectFromWebSocket() {
        self.webSocket.disconnect()
    }
    
    private func requestMediaAccess(option: MediaOption, completionHandler: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.audio) { audioGranted in
            if option.hasVideo {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { videoGranted in
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
            
        }
    }
    
    func updateMeidaShare(call:Call, mediaShare: MediaShareModel,completionHandler: @escaping ((Error?) -> Void)) {
        if let mediaShareUrl = mediaShare.url {
            self.client.updateMediaShare(mediaShare, by: call.device, mediaShareUrl: mediaShareUrl, queue: self.queue.underlying) { res in
                self.doLocusResponse(LocusResult.updateMediaShare(call, res,completionHandler))
                self.queue.yield()
            }
        } else {
            let error = SparkError.serviceFailed(code: -700, reason: "Unsupport media share.")
            completionHandler(error)
            SDKLogger.shared.error("Failure", error: error)
        }
        
    }
    
}
