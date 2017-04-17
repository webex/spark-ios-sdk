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

import CoreMedia

/// A Call represents a media call on Cisco Spark.
/// The application can create an outgoing *call* object by calling *phone.dial* function:
///
/// ``` swift
///     let address = "coworker@example.com"
///     let localVideoView = MediaRenderView()
///     let remoteVideoView = MediaRenderView()
///     let mediaOption = MediaOption.audioVideo(local: localVideoView, remote: remoteVideoView)
///     let call = spark.phone.dial(address, option: mediaOption) { success in
///       if success {
///         // success
///       } else {
///         // failure
///       }
///     }
/// ```
/// The application can receive an incoming *call* object via ...
///
/// ``` swift
///    code
/// ```
///
/// - see: Phone API about how to create calls.
/// - since: 1.2.0
public class Call {
    
    public enum Direction {
        case incoming
        case outgoing
    }
    
    public enum DisconnectType {
        case localLeft
        case localDecline
        case localCancel
        case remoteLeft
        case remoteDecline
        case remoteCancel
        case otherConnected
        case otherDeclined
    }
    
    public enum MediaChangeType {
        case remoteSendingVideo(Bool)
        case remoteSendingAudio(Bool)
        case sendingVideo(Bool)
        case sendingAudio(Bool)
        case receivingVideo(Bool)
        case receivingAudio(Bool)
        case cameraSwitched
        case spearkerSwitched
        case localVideoViewSize
        case remoteVideoViewSize
    }
    
    public enum Capabilities {
        case dtmf
    }
    
    /// Callback when remote participant(s) is ringing.
    public var onRinging: (() -> Void)?
    
    /// Callback when remote participant(s) answered and call gets connected.
    public var onConnected: (() -> Void)?
    
    /// Callback when call gets disconnected (hangup, cancelled, get declined or other self device pickup the call).
    public var onDisconnected: ((DisconnectType) -> Void)?
    
    public var onMediaChanged: ((MediaChangeType) -> Void)?
    
    public var onCapabilitiesChanged: ((Capabilities) -> Void)?
    
    public var onError: ((Error) -> Void)?
    
    public internal(set) var status: CallStatus = CallStatus.initiated
    
    public private(set) var direction: Direction
    
    public var id: String {
        return self.model.myself?[device: self.device.deviceUrl]?.callLegId ?? self.sessionId
    }
    
    public var sessionId: String {
        return URL(string: self.url)!.lastPathComponent
    }
    
    /// True if the DTMF keypad is enabled for this *call*. Otherwise, false.
    public var sendingDTMFEnabled: Bool {
        return self.model.isLocalSupportDTMF
    }
    
    /// True if the remote party of this *call* is sending video. Otherwise, false.
    public var remoteSendingVideo: Bool {
        return !model.isRemoteVideoMuted
    }
    
    /// True if the remote party of this *call* is sending audio. Otherwise, false.
    public var remoteSendingAudio: Bool {
        return !model.isRemoteAudioMuted
    }
    
    /// True if the local party of this *call* is sending video. Otherwise, false.
    public var sendingVideo: Bool {
        get {
            return self.mediaSession.hasVideo && !self.mediaSession.videoMuted
        }
        set {
            self.mediaSession.videoMuted = !newValue
        }
    }
    
    /// True if this *call* is sending audio. Otherwise, false.
    public var sendingAudio: Bool {
        get {
            return self.mediaSession.hasAudio && !self.mediaSession.audioMuted
        }
        set {
            self.mediaSession.audioMuted = !newValue
        }
    }
    
    /// True if the local party of this *call* is receiving video. Otherwise, false.
    public var receivingVideo: Bool {
        get {
            return self.mediaSession.hasVideo && !self.mediaSession.videoOutputMuted
        }
        set {
            self.mediaSession.videoOutputMuted = !newValue
        }
    }
    
    /// True if the local party of this *call* is receiving audio. Otherwise, false.
    public var receivingAudio: Bool {
        get {
            return self.mediaSession.hasAudio && !self.mediaSession.audioOutputMuted
        }
        set {
            self.mediaSession.audioOutputMuted = !newValue
        }
    }
    
    /// True if loud speaker is selected as the audio output device for this *call*. Otherwise, false.
    public var isSpeaker: Bool {
        get {
            return self.mediaSession.isSpeakerSelected()
        }
        set {
            // TODO
        }
    }
    
    /// The camera facing mode selected for this *call*.
    public var facingMode: MediaOption.FacingMode {
        get {
            return self.mediaSession.isFrontCameraSelected() ? .user : .environment
        }
        set {
            // TODO
        }
    }
    
    /// The local video render view dimensions (points) of this *call*.
    public var localVideoViewSize: CMVideoDimensions {
        return CMVideoDimensions(width: self.mediaSession.localVideoViewWidth, height: self.mediaSession.localVideoViewHeight)
    }
    
    /// The remote video render view dimensions (points) of this *call*.
    public var remoteVideoViewSize: CMVideoDimensions {
        return CMVideoDimensions(width: self.mediaSession.remoteVideoViewWidth, height: self.mediaSession.remoteVideoViewHeight)
    }
    
    public var memberships: [CallMembership] {
        if let participants = self.model.participants {
            return participants.map { participant in
                return CallMembership(participant: participant, call: self)
            }
        }
        return []
    }
    
    var model: CallModel {
        get { lock(); defer { unlock() }; return _model }
        set { lock(); defer { unlock() }; _model = newValue }
    }
    
    var url: String {
        return self.model.callUrl!
    }
    
    let device: Device
    let mediaSession: MediaSessionWrapper
    
    private let dtmfQueue: DtmfQueue
    private var _dail: String?
    private var _model: CallModel
    private var mutex = pthread_mutex_t()
    

    private var remoteSDP: String? {
        return self.model.myself?[device: self.device.deviceUrl]?.mediaConnections?.first?.remoteSdp?.sdp
    }
    
    init(model: CallModel, device: Device, media: MediaSessionWrapper, direction: Direction) {
        self.direction = direction
        self.device = device
        self.mediaSession = media
        self._model = model
        self.dtmfQueue = DtmfQueue(client: device.phone.client)
    }
    
    deinit{
        pthread_mutex_init(&mutex, nil)
    }
    
    @inline(__always) private func lock(){
        pthread_mutex_lock(&mutex)
    }
    @inline(__always) private func unlock(){
        pthread_mutex_unlock(&mutex)
    }
    
    /// This function disconnects this *call*. This applies to both incoming and outgoing calls.
    ///
    /// - returns: Void
    public func hangup() {
        self.device.phone.hangup(call: self)
    }
    
    /// Rejects an incoming call. This only applies to incoming calls.
    ///
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    public func reject() {
        self.device.phone.reject(call: self)
    }
    
    /// Send feed back to Spark.
    ///
    /// - parameter rating: Rating between 1 and 5.
    /// - parameter comments: User comments.
    /// - parameter includeLogs: True if to include logs, False as not.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    public func sendFeedbackWith(rating: Int, comments: String? = nil, includeLogs: Bool = false) {
        // TODO
        //        guard let info = info else {
        //            SDKLogger.error("Failure: Missing call info for feedback")
        //            return
        //        }
        //
        //        let feedback = Feedback(rating: rating, comments: comments, includeLogs: includeLogs)
        //        callMetrics.submit(feedback: feedback, callInfo: info, deviceUrl: deviceUrl)
    }
    
    /// This function sends DTMF events to the remote party. Valid DTMF events are 0-9, *, #, a-d, and A-D.
    ///
    /// - parameter dtmf: any combination of valid DTMF events matching regex mattern "^[0-9#\*abcdABCD]+$"
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    public func send(dtmf: String, completionHandler: ((Error?) -> Void)?) {
        guard let url = self.model.myself?.url else {
            SDKLogger.error("Failure: Missing self participant URL")
            DispatchQueue.main.async {
                self.onError?(SparkErrors.missingAttributes)
            }
            return
        }
        if sendingDTMFEnabled {
            self.dtmfQueue.push(participantUrl: url, device: self.device, event: dtmf, completionHandler: completionHandler)
        } else {
            DispatchQueue.main.async {
                completionHandler?(SparkErrors.unsupported)
            }
        }
    }
    
    /// This function answers an incoming call. It only applies to incoming calls.
    /// Calling this function on outgoing calls behaves ?
    ///
    /// - parameter option: Intended media options - audio only or audio and video - for the call.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    public func answer(option: MediaOption) {
        self.device.phone.answer(call: self, option: option)
    }
    
    func updateMedia(sendingAudio: Bool, sendingVideo: Bool) {
        self.device.phone.update(call: self, sendingAudio: sendingAudio, sendingVideo: sendingVideo)
    }
    
    func startMedia() {
        if let remoteSDP = self.model.myself?[device: self.device.deviceUrl]?.mediaConnections?.first?.remoteSdp?.sdp {
            self.mediaSession.setRemoteSdp(remoteSDP)
        }
        else {
            SDKLogger.error("Failure: remoteSdp is nil")
        }
        self.mediaSession.startMedia(call: self)
    }
    
    func stopMedia() {
        self.mediaSession.stopMedia()
    }
    
    func doCallModel(_ model: CallModel) {
        if model.isValid {
            let old = self.model
            if let new = CallEventSequencer.sequence(old: old, new: model, invalid: { self.device.phone.fetch(call: self) }) {
                self.model = new
                self.status.handle(model: new, for: self)
                DispatchQueue.main.async {
                    if new.isRemoteVideoMuted != old.isRemoteVideoMuted {
                        self.onMediaChanged?(MediaChangeType.remoteSendingVideo(new.isRemoteVideoMuted))
                    }
                    if new.isRemoteAudioMuted != old.isRemoteAudioMuted {
                        self.onMediaChanged?(MediaChangeType.remoteSendingAudio(new.isRemoteAudioMuted))
                    }
                    if new.isLocalSupportDTMF != old.isLocalSupportDTMF {
                        self.onCapabilitiesChanged?(Capabilities.dtmf)
                    }
                }
            }
        }
    }
}


