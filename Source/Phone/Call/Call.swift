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

import CoreMedia

/// A Call represents a media call on Cisco Spark.
///
/// The application can create an outgoing *call* by calling *phone.dial* function:
///
/// ```` swift
///     let address = "coworker@example.com"
///     let localVideoView = MediaRenderView()
///     let remoteVideoView = MediaRenderView()
///     let mediaOption = MediaOption.audioVideo(local: localVideoView, remote: remoteVideoView)
///     spark.phone.dial(address, option:mediaOption) {
///       switch ret {
///       case .success(let call):
///         // success
///         call.onConnected = {
///
///         }
///         call.onDisconnected = { reason in
///
///         }
///       case .failure(let error):
///         // failure
///       }
///     }
/// ````
///
/// The application can receive an incoming *call* on *phone.onIncoming* function:
///
/// ```` swift
///     spark.phone.onIncoming = { call in
///       call.answer(option: mediaOption) { error in
///         if let error = error {
///           // success
///         }
///         else {
///           // failure
///         }
///       }
///     }
/// ````
///
/// - see: see Phone API about how to create calls.
/// - see: CallStatus for the states and transitions of a *Call*.
/// - since: 1.2.0
public class Call {
    
    /// The enumeration of directions of a call
    ///
    /// - since: 1.2.0
    public enum Direction {
        /// The local party is a recipient of the call.
        case incoming
        /// The local party is an initiator of the call.
        case outgoing
    }
    
    /// The enumuaration of reasons for a call being disconnected.
    ///
    /// - since: 1.2.0
    public enum DisconnectReason {
        /// The local party has left the call.
        case localLeft
        /// The local party has declined the call.
        /// This is only applicable when the *direction* of the call is *incoming*.
        case localDecline
        /// The local party has cancelled the call.
        /// This is only applicable when the *direction* of the call is *outgoing*.
        case localCancel
        /// The remote party has left the call.
        case remoteLeft
        /// The remote party has declined the call.
        /// This is only applicable when the *direction* of the call is *outgoing*.
        case remoteDecline
        /// The remote party has cancelled the call.
        /// This is only applicable when the *direction* of the call is *incoming*.
        case remoteCancel
        /// One of the other phones of the authenticated user has answered the call.
        /// This is only applicable when the *direction* of the call is *incoming*.
        case otherConnected
        /// One of the other phones of the authenticated user has declined the call.
        /// This is only applicable when the *direction* of the call is *incoming*.
        case otherDeclined
        /// Unknown error
        case error(Error)
    }
    
    /// The enumeration of media change event
    ///
    /// - since: 1.2.0
    public enum MediaChangedEvent {
        /// True if the remote party now is sending video. Otherwise false.
        /// This might be triggered when the remote party muted or unmuted the video.
        case remoteSendingVideo(Bool)
        /// True if the remote party now is sending audio. Otherwise false.
        /// This might be triggered when the remote party muted or unmuted the audio.
        case remoteSendingAudio(Bool)
        /// True if the local party now is sending video. Otherwise false.
        /// This might be triggered when the local party muted or unmuted the video.
        case sendingVideo(Bool)
        /// True if the local party now is sending aduio. Otherwise false.
        /// This might be triggered when the local party muted or unmuted the audio.
        case sendingAudio(Bool)
        /// True if the local party now is receiving video. Otherwise false.
        /// This might be triggered when the local party muted or unmuted the video.
        case receivingVideo(Bool)
        /// True if the local party now is receiving audio. Otherwise false.
        /// This might be triggered when the local party muted or unmuted the audio.
        case receivingAudio(Bool)
        /// Camera FacingMode on local device has switched.
        case cameraSwitched
        /// Whether loud speaker on local device is on or not has switched.
        case spearkerSwitched
        /// Local video rendering view size has changed.
        case localVideoViewSize
        /// Remote video rendering view size has changed.
        case remoteVideoViewSize
        /// Screen share rendering view size has changed.
        ///
        /// - since: 1.3.0
        case remoteScreenShareViewSize
        /// True if the local party now is receiving screen share. Otherwise false.
        /// This might be triggered when the local party muted or unmuted the video
        /// if screen sharing is sent via the video stream.
        /// This might also be triggered when the local party started or stopped the screen share.
        ///
        /// - since: 1.3.0
        case receivingScreenShare(Bool)
        /// True if the screen share now is receiving and joined. Otherwise false.
        /// This might be triggered when the remote party started or stopped share stream.
        ///
        /// - since: 1.3.0
        case remoteSendingScreenShare(Bool)
        /// True if the screen share now is sending. Otherwise false.
        /// This might be triggered when the local started or stopped share stream.
        ///
        /// - since: 1.4.0
        case sendingScreenShare(Bool)
        /// Local screen share size has changed.
        /// - since: 1.4.0
        case localScreenShareViewSize
    }
    
    /// The enumeration of call membership events.
    ///
    /// - since: 1.3.0
    public enum CallMembershipChangedEvent {
        /// The person in the membership joined this *call*.
        case joined(CallMembership)
        /// The person in the membership left this *call*.
        case left(CallMembership)
        /// The person in the membership declined this *call*.
        case declined(CallMembership)
        /// The person in the membership started sending video this *call*.
        case sendingVideo(CallMembership)
        /// The person in the membership started sending audio.
        case sendingAudio(CallMembership)
        /// The person in the membership started screen sharing.
        case sendingScreenShare(CallMembership)
    }
    
    /// The enumeration of iOS broadcasting events.
    ///
    /// - since: 1.4.0
    public enum iOSBroadcastingEvent {
        /// When broadcast extension connected to this call.
        case extensionConnected
        /// When broadcast extension disconneted to this call.
        case extensionDisconnected
    }
    
    /// The enumeration of capabilities of a call.
    ///
    /// - since: 1.2.0
    public enum Capabilities {
        /// This *call* can send and receive DTMF.
        case dtmf
    }
    
    /// Callback when remote participant(s) is ringing.
    ///
    /// - since: 1.2.0
    public var onRinging: (() -> Void)? {
        didSet {
            self.device.phone.queue.sync {
                if let block = self.onRinging, self.status == CallStatus.ringing {
                    DispatchQueue.main.async {
                        block()
                    }
                }
                self.device.phone.queue.yield()
            }
        }
    }
    
    /// Callback when remote participant(s) answered and this *call* is connected.
    ///
    /// - since: 1.2.0
    public var onConnected: (() -> Void)? {
        didSet {
            self.device.phone.queue.sync {
                self.onConnectedOnceToken = UUID().uuidString
                if let block = self.onConnected, self.status == CallStatus.connected {
                    DispatchQueue.main.asyncOnce(token: self.onConnectedOnceToken) {
                        block()
                    }
                }
                self.device.phone.queue.yield()
            }
        }
    }
    
    /// Callback when this *call* is disconnected (hangup, cancelled, get declined or other self device pickup the call).
    ///
    /// - since: 1.2.0
    public var onDisconnected: ((DisconnectReason) -> Void)?
    
    /// Callback when the memberships of this *call* have changed.
    ///
    /// - since: 1.3.0
    public var onCallMembershipChanged: ((CallMembershipChangedEvent) -> Void)?
    
    /// Callback when the media types of this *call* have changed.
    ///
    /// - since: 1.2.0
    public var onMediaChanged: ((MediaChangedEvent) -> Void)?
    
    /// Callback when the capabilities of this *call* have changed.
    ///
    /// - since: 1.2.0
    public var onCapabilitiesChanged: ((Capabilities) -> Void)?
    
    /// Callback when the iOS broadcasting status of this *call* have changed.
    ///
    /// - since: 1.4.0
    public var oniOSBroadcastingChanged: ((iOSBroadcastingEvent) -> Void)?
    
    /// The status of this *call*.
    ///
    /// - since: 1.2.0
    /// - see: CallStatus
    public internal(set) var status: CallStatus = CallStatus.initiated
    
    /// The direction of this *call*.
    ///
    /// - since: 1.2.0
    public private(set) var direction: Direction
    
    /// True if the DTMF keypad is enabled for this *call*. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var sendingDTMFEnabled: Bool {
        return self.model.isLocalSupportDTMF
    }
    
    /// True if the remote party of this *call* is sending video. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var remoteSendingVideo: Bool {
        return !model.isRemoteVideoMuted
    }
    
    /// True if the remote party of this *call* is sending audio. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var remoteSendingAudio: Bool {
        return !model.isRemoteAudioMuted
    }
    
    /// True if the remote party of this *call* is sending screen share. Otherwise, false.
    ///
    /// - since: 1.3.0
    public var remoteSendingScreenShare: Bool {
        return model.isGrantedScreenShare && !self.isScreenSharedBySelfDevice()
    }
    
    /// True if the local party of this *call* is sending video. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var sendingVideo: Bool {
        get {
            return self.mediaSession.hasVideo && !self.mediaSession.videoMuted
        }
        set {
            self.mediaSession.videoMuted = !newValue
        }
    }
    
    /// True if this *call* is sending audio. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var sendingAudio: Bool {
        get {
            return self.mediaSession.hasAudio && !self.mediaSession.audioMuted
        }
        set {
            self.mediaSession.audioMuted = !newValue
        }
    }
    
    /// True if the local party of this *call* is sending screen share. Otherwise, false.
    ///
    /// - since: 1.4.0
    public var sendingScreenShare: Bool {
        get {
            return self.mediaSession.hasScreenShare && !self.mediaSession.screenShareMuted && self.isScreenSharedBySelfDevice()
        }
        set {
            self.mediaSession.screenShareMuted = !newValue
        }
    }
    
    /// True if the local party of this *call* is receiving video. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var receivingVideo: Bool {
        get {
            return self.mediaSession.hasVideo && !self.mediaSession.videoOutputMuted
        }
        set {
            self.mediaSession.videoOutputMuted = !newValue
        }
    }
    
    /// True if the local party of this *call* is receiving audio. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var receivingAudio: Bool {
        get {
            return self.mediaSession.hasAudio && !self.mediaSession.audioOutputMuted
        }
        set {
            self.mediaSession.audioOutputMuted = !newValue
        }
    }
    
    /// True if the local party of this *call* is receiving screen share. Otherwise, false.
    ///
    /// - since: 1.3.0
    public var receivingScreenShare: Bool {
        get {
            if !self.mediaSession.hasScreenShare && self.mediaSession.hasVideo {
                return !self.mediaSession.videoOutputMuted
            }
            else {
                return self.mediaSession.hasScreenShare && !self.mediaSession.screenShareOutputMuted
            }
        }
        set {
            if !self.mediaSession.hasScreenShare && self.mediaSession.hasVideo && self.model.isGrantedScreenShare {
                self.receivingVideo = newValue
            } else if self.mediaSession.hasScreenShare {
                self.mediaSession.screenShareOutputMuted = !newValue
            } else {
                // not have screen share and have video and the remote doesn't start screen share.
                // do nothing when user set the receivingScreenShare
            }
        }
    }
    
    /// True if the loud speaker is selected as the audio output device for this *call*. Otherwise, false.
    ///
    /// - since: 1.2.0
    public var isSpeaker: Bool {
        get {
            return self.mediaSession.isSpeakerSelected()
        }
        set {
            self.mediaSession.setLoudSpeaker(speaker: newValue)
        }
    }
    
    /// The camera facing mode selected for this *call*.
    ///
    /// - since: 1.2.0
    public var facingMode: Phone.FacingMode {
        get {
            return self.mediaSession.isFrontCameraSelected() ? .user : .environment
        }
        set {
            self.mediaSession.setFacingMode(mode: newValue)
        }
    }
    
    /// The local video render view dimensions (points) of this *call*.
    ///
    /// - since: 1.2.0
    public var localVideoViewSize: CMVideoDimensions {
        return CMVideoDimensions(width: self.mediaSession.localVideoViewWidth, height: self.mediaSession.localVideoViewHeight)
    }
    
    /// The remote video render view dimensions (points) of this *call*.
    ///
    /// - since: 1.2.0
    public var remoteVideoViewSize: CMVideoDimensions {
        return CMVideoDimensions(width: self.mediaSession.remoteVideoViewWidth, height: self.mediaSession.remoteVideoViewHeight)
    }
    
    /// The remote screen share render view dimensions (points) of this *call*.
    ///
    /// - since: 1.3.0
    public var remoteScreenShareViewSize: CMVideoDimensions {
        return CMVideoDimensions(width: self.mediaSession.remoteScreenShareViewWidth, height: self.mediaSession.remoteScreenShareViewHeight)
    }
    
    /// The local screen share render view dimensions (points) of this *call*.
    ///
    /// - since: 1.4.0
    public var localScreenShareViewSize: CMVideoDimensions {
        return CMVideoDimensions(width: self.mediaSession.localScreenShareViewWidth, height: self.mediaSession.localScreenShareViewHeight)
    }
    
    /// Call Memberships represent participants in this *call*.
    ///
    /// - since: 1.2.0
    public private(set) var memberships: [CallMembership] {
        get { lock(); defer { unlock() }; return _memberships ?? [] }
        set { lock(); defer { unlock() }; _memberships = newValue }
    }
    
    /// The initiator of this *call*.
    ///
    /// - since: 1.2.0
    public var from: CallMembership? {
        return self.memberships.filter({ $0.isInitiator }).first
    }
    
    /// The intended recipient of this *call*.
    ///
    /// - since: 1.2.0
    public var to: CallMembership? {
        return self.memberships.filter({ !$0.isInitiator }).first
    }
    
    /// The render views for local and remote video of this call.
    /// If is nil, it will update the video state as inactive to the server side.
    /// - since: 1.3.0
    public var videoRenderViews: (local:MediaRenderView, remote:MediaRenderView)? {
        didSet {
            DispatchQueue.main.async {
                if !self.mediaSession.hasVideo {
                    return
                }
                //update media session
                self.mediaSession.updateMedia(mediaType:MediaSessionWrapper.MediaType.video(self.videoRenderViews))
                //update locus local medias
                self.device.phone.update(call: self, sendingAudio: self.sendingAudio, sendingVideo: self.sendingVideo,localSDP: self.mediaSession.getLocalSdp())
            }
        }
    }
    
    /// The render view for the remote screen share of this call.
    /// If is nil, it will update the screen sharing state as inactive to the server side.
    ///
    /// - since: 1.3.0
    public var screenShareRenderView: MediaRenderView? {
        didSet {
            DispatchQueue.main.async {
                if !self.mediaSession.hasScreenShare {
                    return
                }
                //update media session
                self.mediaSession.updateMedia(mediaType:MediaSessionWrapper.MediaType.screenShare(self.screenShareRenderView))
                //update locus local medias
                self.device.phone.update(call: self, sendingAudio: self.sendingAudio, sendingVideo: self.sendingVideo,localSDP: self.mediaSession.getLocalSdp())
                //join or leave screen share
                if let granted = self.model.screenMediaShare?.shareFloor?.granted {
                    if self.screenShareRenderView != nil {
                        self.mediaSession.joinScreenShare(granted, isSending: false)
                    }
                    else {
                        self.mediaSession.leaveScreenShare(granted, isSending: false)
                    }
                }
            }
        }
    }
    
    var model: CallModel {
        get { lock(); defer { unlock() }; return _model }
        set { lock(); defer { unlock() }; _model = newValue }
    }
    
    var url: String {
        return self.model.callUrl!
    }
    
    let isGroup: Bool
    
    let device: Device
    let mediaSession: MediaSessionWrapper
    var _uuid: UUID
    
    let metrics: CallMetrics
    private let dtmfQueue: DtmfQueue
    
    private var _dail: String?
    private var _model: CallModel
    private var _memberships: [CallMembership]?
    var _mutex = pthread_mutex_t()
    
    var onConnectedOnceToken :String = "" {
        didSet {
            DispatchQueue.main.removeOnceToken(token: oldValue)
        }
    }
    
    private var id: String {
        return self.model.myself?[device: self.device.deviceUrl]?.callLegId ?? self.sessionId
    }
    
    private var sessionId: String {
        return URL(string: self.url)!.lastPathComponent
    }
    
    private var remoteSDP: String? {
        if let remoteSDP = self.model.myself?[device: self.device.deviceUrl]?.mediaConnections?.first?.remoteSdp?.sdp {
                return remoteSDP
            } else if let remoteSDP = self.model.mediaConnections?.first?.remoteSdp?.sdp {
                return remoteSDP
            }
        return nil
    }
    
    init(model: CallModel, device: Device, media: MediaSessionWrapper, direction: Direction, group: Bool, uuid: UUID?) {
        self.direction = direction
        self.isGroup = group
        self.device = device
        self.mediaSession = media
        self._model = model
        self._uuid = uuid ?? UUID()
        self.dtmfQueue = DtmfQueue(client: device.phone.client)
        self.metrics = CallMetrics()
        self.metrics.trackCallStarted()
        self.videoRenderViews = media.videoViews
        self.screenShareRenderView = media.screenShareView
        self.doCallModel(model)
    }
    
    deinit{
        pthread_mutex_init(&_mutex, nil)
        DispatchQueue.main.removeOnceToken(token: self.onConnectedOnceToken)
    }
    
    @inline(__always) func lock(){
        pthread_mutex_lock(&_mutex)
    }
    @inline(__always) func unlock(){
        pthread_mutex_unlock(&_mutex)
    }
    
    /// Acknowledge (without answering) an incoming call.
    /// Will cause the initiator's Call instance to emit the ringing event.
    ///
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - see: see CallStatus
    /// - since: 1.2.0
    public func acknowledge(completionHandler: @escaping (Error?) -> Void) {
        self.device.phone.acknowledge(call: self, completionHandler: completionHandler)
    }
    
    /// Answers this call.
    /// This can only be invoked when this call is incoming and in ringing status.
    ///
    /// - parameter option: Intended media options - audio only or audio and video - for the call.
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - see: see CallStatus
    /// - since: 1.2.0
    public func answer(option: MediaOption, completionHandler: @escaping (Error?) -> Void) {
        self.device.phone.answer(call: self, option: option, completionHandler: completionHandler)
    }
    
    /// Rejects this call. 
    /// This can only be invoked when this call is incoming and in ringing status.
    ///
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - since: 1.2.0
    /// - see: see CallStatus
    public func reject(completionHandler: @escaping (Error?) -> Void) {
        self.device.phone.reject(call: self, completionHandler: completionHandler)
    }
    
    /// Disconnects this call.
    /// This can only be invoked when this call is in answered status.
    ///
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - since: 1.2.0
    /// - see: see CallStatus
    public func hangup(completionHandler: @escaping (Error?) -> Void) {
        self.device.phone.hangup(call: self, completionHandler: completionHandler)
    }

    /// Sends feedback for this call to Cisco Spark team.
    ///
    /// - parameter rating: The rating of the quality of this call between 1 and 5 where 5 means excellent quality.
    /// - parameter comments: The comments for this call.
    /// - parameter includeLogs: True if to include logs, False as not.
    /// - returns: Void
    /// - since: 1.2.0
    public func sendFeedbackWith(rating: Int, comments: String? = nil, includeLogs: Bool = false) {
        self.device.phone.metrics.trackFeedbackMetric(call: self, rating: rating, comments: comments, includeLogs: includeLogs)
    }
    
    /// Sends DTMF events to the remote party. Valid DTMF events are 0-9, *, #, a-d, and A-D.
    ///
    /// - parameter dtmf: any combination of valid DTMF events matching regex mattern "^[0-9#\*abcdABCD]+$"
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.    
    /// - returns: Void
    /// - since: 1.2.0
    public func send(dtmf: String, completionHandler: ((Error?) -> Void)?) {
        if let url = self.model.myself?.url {
            if self.sendingDTMFEnabled {
                self.dtmfQueue.push(participantUrl: url, device: self.device, event: dtmf, completionHandler: completionHandler)
            } else {
                DispatchQueue.main.async {
                    completionHandler?(SparkError.unsupportedDTMF)
                }
            }
        }
        else {
            let error = SparkError.serviceFailed(code: -700, reason: "Missing self participant URL")
            completionHandler?(error)
            SDKLogger.shared.error("Failure", error: error)
        }
    }
    
    /// Start screen sharing in this call.
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - since: 1.4.0
    @available(iOS 11.2, *)
    public func startSharing(completionHandler: @escaping ((Error?) -> Void)) {
        self.device.phone.startSharing(call: self) {
            error in
            if error != nil {
                completionHandler(error)
            }
            else {
                self.mediaSession.onBroadcastError = {
                    screenShareError in
                    switch screenShareError {
                    case .stop, .fatal:
                        self.stopSharing { error in
                            SDKLogger.shared.error("Failure", error: error)
                        }
                    default:
                        break
                    }
                }
                completionHandler(nil)
            }
        }
    }
    
    /// Stop screen sharing in this call.
    /// - parameter completionHandler: A closure to be executed when completed, with error if the invocation is illegal or failed, otherwise nil.
    /// - returns: Void
    /// - since: 1.4.0
    @available(iOS 11.2, *)
    public func stopSharing(completionHandler: @escaping ((Error?) -> Void)) {
        self.device.phone.stopSharing(call: self, completionHandler: completionHandler)
    }
    
    func end(reason: DisconnectReason) {
        //To end this call stop local screen share and broadcasting first.
        if #available(iOS 11.2, *) {
            if self.isScreenSharedBySelfDevice() {
                self.stopSharing() {
                    _ in
                    SDKLogger.shared.info("Unshare screen by call end!")
                }
                self.mediaSession.stopLocalScreenShare()
            }
        }
        
        switch reason {
        case .remoteDecline, .remoteLeft:
            if let url = self.model.myself?.url {
                self.device.phone.client.leave(url, by: self.device, queue: self.device.phone.queue.underlying) { res in
                    switch res.result {
                    case .success(let model):
                        SDKLogger.shared.debug("Receive leave locus response: \(model.toJSONString(prettyPrint: self.device.phone.debug) ?? "Nil JSON")")
                    case .failure(let error):
                        SDKLogger.shared.error("Failure leave ", error: error)
                    }
                }
            }
            fallthrough
        default:
            self.device.phone.remove(call: self)
            self.status = .disconnected
            self.metrics.trackCallEnded(reason: reason)
            DispatchQueue.main.async {
                self.stopMedia()
                self.onDisconnected?(reason)
            }
        }
    }
    
    func updateMedia(sendingAudio: Bool, sendingVideo: Bool) {
        self.device.phone.update(call: self, sendingAudio: sendingAudio, sendingVideo: sendingVideo)
    }
    
    func startMedia() {
        if let remoteSDP = self.remoteSDP {
            self.mediaSession.setRemoteSdp(remoteSDP)
        }
        else {
            SDKLogger.shared.error("Failure: remoteSdp is nil")
        }
        self.mediaSession.onBroadcasting = {
            isBroadcasting in
            DispatchQueue.main.async {
                self.oniOSBroadcastingChanged?(isBroadcasting ? iOSBroadcastingEvent.extensionConnected : iOSBroadcastingEvent.extensionDisconnected)
            }
        }
        self.mediaSession.startMedia(call: self)
        if let granted = self.model.screenShareMediaFloor?.granted, self.mediaSession.hasScreenShare {
            self.mediaSession.joinScreenShare(granted, isSending: self.isScreenSharedBySelfDevice())
        }
    }
    
    func stopMedia() {
        //stopMedia must run in the main thread.Because WME will remove the videoRender view.
        if let granted = self.model.screenShareMediaFloor?.granted ,self.mediaSession.hasScreenShare{
            self.mediaSession.leaveScreenShare(granted, isSending: self.isScreenSharedBySelfDevice())
        }
        self.mediaSession.onBroadcasting = nil
        self.mediaSession.stopMedia()
    }
    
    func isScreenSharedBySelfDevice(shareFloor:MediaShareModel.MediaShareFloor? = nil) -> Bool {
        let floor = shareFloor ?? self.model.screenShareMediaFloor
        if let _ = floor?.granted, self.mediaSession.hasScreenShare,floor?.disposition == MediaShareModel.ShareFloorDisposition.granted {
            if let shareScreenDevice = floor?.beneficiary?.deviceUrl {
                if self.device.deviceUrl.absoluteString == shareScreenDevice {
                    return true
                }
            }
        }
        return false
    }
    
    func update(model: CallModel) {
        if model.isValid {
            let old = self.model
            if var new = CallEventSequencer.sequence(old: old, new: model, invalid: { self.device.phone.fetch(call: self) }) {
                //some response's mediaConnection is nil, sync all model hold the latest media connection
                if new.mediaConnections == nil, let oldMediaConnextions = old.mediaConnections {
                    new.setMediaConnections(newMediaConnections: old.mediaConnections)
                }
                
                self.doCallModel(new)
                DispatchQueue.main.async {
                    if new.isRemoteVideoMuted != old.isRemoteVideoMuted {
                        self.onMediaChanged?(MediaChangedEvent.remoteSendingVideo(!new.isRemoteVideoMuted))
                    }
                    if new.isRemoteAudioMuted != old.isRemoteAudioMuted {
                        self.onMediaChanged?(MediaChangedEvent.remoteSendingAudio(!new.isRemoteAudioMuted))
                    }
                    if new.isLocalSupportDTMF != old.isLocalSupportDTMF {
                        self.onCapabilitiesChanged?(Capabilities.dtmf)
                    }
                    
                    func leaveScreenShare(participant: ParticipantModel, granted: String, oldFloor:MediaShareModel.MediaShareFloor? = nil) {
                        if self.isScreenSharedBySelfDevice(shareFloor: oldFloor) {
                            if self.mediaSession.hasScreenShare {
                                self.mediaSession.stopLocalScreenShare()
                                self.mediaSession.leaveScreenShare(granted, isSending: true)
                            }
                            self.onMediaChanged?(MediaChangedEvent.sendingScreenShare(false))
                        } else {
                            if self.mediaSession.hasScreenShare {
                                self.mediaSession.leaveScreenShare(granted, isSending: false)
                            }
                            self.onMediaChanged?(MediaChangedEvent.remoteSendingScreenShare(false))
                        }
                        
                        if let membership = self.memberships.filter({$0.id == participant.id}).first {
                            self.onCallMembershipChanged?(CallMembershipChangedEvent.sendingScreenShare(membership))
                        }
                    }
                    
                    func joinScreenShare(participant: ParticipantModel, granted: String) {
                        if self.isScreenSharedBySelfDevice() {
                            if self.mediaSession.hasScreenShare {
                                self.mediaSession.startLocalScreenShare()
                                self.mediaSession.joinScreenShare(granted, isSending: true)
                            }
                            if !self.mediaSession.screenShareMuted {
                              self.onMediaChanged?(MediaChangedEvent.sendingScreenShare(true))
                            }
                        } else {
                            if self.mediaSession.hasScreenShare {
                                self.mediaSession.joinScreenShare(granted, isSending: false)
                            }
                            self.onMediaChanged?(MediaChangedEvent.remoteSendingScreenShare(true))
                        }
                        if let membership = self.memberships.filter({$0.id == participant.id}).first {
                            if self.isScreenSharedBySelfDevice() && self.mediaSession.screenShareMuted {
                                
                            } else {
                                self.onCallMembershipChanged?(CallMembershipChangedEvent.sendingScreenShare(membership))
                            }
                        }
                    }
                    
                    func replaceScreenShare(newFloor:MediaShareModel.MediaShareFloor, oldFloor:MediaShareModel.MediaShareFloor) {
                        //someone replace my screen sharing
                        if self.isScreenSharedBySelfDevice(shareFloor: oldFloor) == true && self.isScreenSharedBySelfDevice(shareFloor: newFloor) == false {
                            if self.mediaSession.hasScreenShare {
                                self.mediaSession.stopLocalScreenShare()
                                self.mediaSession.leaveScreenShare(oldFloor.granted!, isSending: true)
                                self.mediaSession.joinScreenShare(newFloor.granted!, isSending: false)
                            }
                            self.onMediaChanged?(MediaChangedEvent.sendingScreenShare(false))
                            self.onMediaChanged?(MediaChangedEvent.remoteSendingScreenShare(true))
                            
                        } else if self.isScreenSharedBySelfDevice(shareFloor: oldFloor) == false && self.isScreenSharedBySelfDevice(shareFloor: newFloor) == true {
                            if self.mediaSession.hasScreenShare {
                                self.mediaSession.leaveScreenShare(oldFloor.granted ?? newFloor.granted!, isSending: false)
                                self.mediaSession.joinScreenShare(newFloor.granted!, isSending: true)
                                self.mediaSession.startLocalScreenShare()
                            }
                            self.onMediaChanged?(MediaChangedEvent.remoteSendingScreenShare(false))
                            if !self.mediaSession.screenShareMuted {
                                self.onMediaChanged?(MediaChangedEvent.sendingScreenShare(true))
                            }
                        } else {
                            
                        }
                        if let sharingParticipantId = newFloor.beneficiary?.id ,let membership = self.memberships.filter({$0.id == sharingParticipantId}).first{
                            self.onCallMembershipChanged?(CallMembershipChangedEvent.sendingScreenShare(membership))
                        }
                    }
                    
                    //screen share
                    if let newFloor = new.screenShareMediaFloor, let _ = newFloor.beneficiary?.id, let newGranted = newFloor.granted, let newDisposition = newFloor.disposition {
                        if let oldFloor = old.screenShareMediaFloor, let _ = oldFloor.beneficiary?.id, let oldDisposition = oldFloor.disposition {
                            if newDisposition != oldDisposition {
                                if newDisposition == MediaShareModel.ShareFloorDisposition.granted {
                                    joinScreenShare(participant: newFloor.beneficiary!, granted: newGranted)
                                }
                                else if newDisposition == MediaShareModel.ShareFloorDisposition.released {
                                    leaveScreenShare(participant: oldFloor.granted != nil ? oldFloor.beneficiary! : newFloor.beneficiary!, granted: oldFloor.granted ?? newGranted,oldFloor: oldFloor)
                                }
                                else {
                                    SDKLogger.shared.error("Failure: floor dispostion is unknown.")
                                }
                            }
                            else if let oldGranted = oldFloor.granted, newGranted != oldGranted, newDisposition == MediaShareModel.ShareFloorDisposition.granted {
                                replaceScreenShare(newFloor: newFloor, oldFloor: oldFloor)
                            }
                        }
                        else {
                            if newDisposition == MediaShareModel.ShareFloorDisposition.granted {
                                joinScreenShare(participant: newFloor.beneficiary!, granted: newGranted)
                            }
                            else if newDisposition == MediaShareModel.ShareFloorDisposition.released {
                                leaveScreenShare(participant: newFloor.beneficiary!, granted: newGranted)
                            }
                            else {
                                SDKLogger.shared.error("Failure: floor dispostion is unknown.")
                            }
                        }
                    }                    
                }
            } else {
                //some response's mediaConnection is nil, sync all model hold the latest media connection
                if self.model.mediaConnections == nil, let mediaConnection = model.mediaConnections {
                    self.model.setMediaConnections(newMediaConnections: mediaConnection)
                }
            }
        }
    }
    
    private func doCallModel(_ model: CallModel) {
        self.model = model
        if let participants = model.participants?.filter({ $0.isCIUser() }) {
            let oldMemberships = self.memberships
            var newMemberships = [CallMembership]()
            var onCallMembershipChanges = [CallMembershipChangedEvent]()
            
            for participant in participants {
                if var membership = oldMemberships.find(predicate: { $0.id == participant.id }) {
                    let oldState = membership.state
                    let sendingAudio = membership.sendingAudio
                    let sendingVideo = membership.sendingVideo
                    membership.model = participant
                    if membership.state != oldState {
                        if membership.state == CallMembership.State.joined {
                            onCallMembershipChanges.append(CallMembershipChangedEvent.joined(membership))
                        }
                        else if membership.state == CallMembership.State.left {
                            onCallMembershipChanges.append(CallMembershipChangedEvent.left(membership))
                        }
                        else if membership.state == CallMembership.State.declined {
                            onCallMembershipChanges.append(CallMembershipChangedEvent.declined(membership))
                        }
                    }
                    if membership.sendingAudio != sendingAudio {
                        onCallMembershipChanges.append(CallMembershipChangedEvent.sendingAudio(membership))
                    }
                    if membership.sendingVideo != sendingVideo {
                        onCallMembershipChanges.append(CallMembershipChangedEvent.sendingVideo(membership))
                    }
                    newMemberships.append(membership)
                }
                else {
                    newMemberships.append(CallMembership(participant: participant, call: self))
                }
            }
            self.memberships = newMemberships
            for callMembershipChange in onCallMembershipChanges {
                DispatchQueue.main.async {
                    self.onCallMembershipChanged?(callMembershipChange)
                }
            }
        }
        else {
            self.memberships = []
        }
        self.status.handle(model: model, for: self)
    }
}

extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    func asyncOnce(token: String, block:@escaping ()->Void) {
        self.async {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            if token.isEmpty || DispatchQueue._onceTracker.contains(token) {
                return
            }
            DispatchQueue._onceTracker.append(token)
            block()
        }
    }
    
    func removeOnceToken(token: String) {
        self.async {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            if token.isEmpty {
                return
            }
            DispatchQueue._onceTracker.removeObject(token)
        }
    }
}



