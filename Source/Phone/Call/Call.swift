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


/// Represents a Spark call.
open class Call {
    
    /// Completion handler for a call operation.
    public typealias CompletionHandler = (Bool) -> Void
    
    /// Camera facing mode.
    public enum FacingMode: String {
        /// Front camera.
        case User
        /// Back camera.
        case Environment
    }
    
    /// Call status.
    public enum Status: String {
        /// Intended recipient hasn't accepted the call.
        case Initiated
        /// Remote party has acknowledged the call.
        case Ringing
        /// An incoming call from remote party.
        case Incoming
        /// Call gets connected.
        case Connected
        /// Call gets disconnected.
        case Disconnected
    }
    
    /// Call status.
    open var status: Status {
        return state.status
    }

    /// The intended recipient of the call. 
    /// For an outgoing call this is the same as the address specified in dial. 
    /// For an incoming call this is the identity of the authenticated user.
    open var to: String?
    
    /// The receiver of the call. 
    /// For an outgoing call this is the identity of the authenticated user.
    /// For an incoming call this is the email address / phone number / SIP address of the caller.
    open var from: String?
    
    /// True if client is sending audio.
    open var sendingAudio: Bool {
        return !mediaSession.audioMuted
    }
    
    /// True if client is receiving audio.
    open var receivingAudio: Bool {
        return !mediaSession.audioOutputMuted
    }
    
    /// True if client is sending video.
    open var sendingVideo: Bool {
        return mediaSession.hasVideo && !mediaSession.videoMuted
    }
    
    /// True if client is receiving video.
    open var receivingVideo: Bool {
        return mediaSession.hasVideo && !mediaSession.videoOutputMuted
    }
    
    /// True if remote is sending audio.
    open var remoteSendingAudio: Bool {
        if let info = self.info {
            return !info.remoteAudioMuted
        }
        return false
    }
    
    /// True if remote is sending video.
    open var remoteSendingVideo: Bool {
        if let info = self.info {
            return !info.remoteVideoMuted
        }
        return false
    }
    
    /// True if loud speaker is selected as the output device for this call.
    open var loudSpeaker: Bool {
        return mediaSession.isSpeakerSelected()
    }
    
    /// Camera facing mode selected for this call.
    open var facingMode: FacingMode {
        return mediaSession.isFrontCameraSelected() ? .User : .Environment
    }
    
    /// Local video render view height.
    open var localVideoViewHeight: UInt32 {
        return mediaSession.localVideoViewHeight
    }
    
    /// Local video render view width.
    open var localVideoViewWidth: UInt32 {
        return mediaSession.localVideoViewWidth
    }
    
    /// Remote video render view height.
    open var remoteVideoViewHeight: UInt32 {
        return mediaSession.remoteVideoViewHeight
    }
    
    /// Remote video render view width.
    open var remoteVideoViewWidth: UInt32 {
        return mediaSession.remoteVideoViewWidth
    }
    
    /// True if the DTMF keypad can be enabled for Client.
    open var sendingDTMFEnabled: Bool {
        if let enableDTMF = info?.enableDTMF {
            return enableDTMF
        } else {
            return false
        }
    }
    
    private var info: CallInfo?
    
    private var selfParticipantUrl: String? {
        return info?.myself?.url
    }
    
    var state: CallState
    private var url: String { return info?.callUrl ?? "" }
    
    private let mediaEngine = MediaEngineWrapper.sharedInstance
    private let mediaSession: MediaSessionWrapper
    // XXX reduce scope to increase information hiding in this class
    let deviceUrl: URL
    private var dtmfQueue: DtmfQueue
    private let callClient: CallClient
    private let callManager: CallManager
    private let callMetrics: CallMetrics
    var callNotificationCenter: CallNotificationCenter {
        return callManager.callNotificationCenter
    }
    
    init(callManager: CallManager, callClient: CallClient, deviceUrl: URL, callMetrics: CallMetrics) {
        self.callManager = callManager
        self.callClient = callClient
        self.deviceUrl = deviceUrl
        self.callMetrics = callMetrics
        mediaSession = MediaSessionWrapper(callManager: callManager)
        state = CallStateIdle()
        dtmfQueue = DtmfQueue(callClient: callClient)
    }
    
    init(_ info: CallInfo, callManager: CallManager, callClient: CallClient, deviceUrl: URL, callMetrics: CallMetrics) {
        self.info = info
        self.callManager = callManager
        self.callClient = callClient
        self.deviceUrl = deviceUrl
        self.callMetrics = callMetrics
        mediaSession = MediaSessionWrapper(callManager: callManager)
        to = info.selfEmail
        from = info.hostEmail
        state = CallStateIncoming()
        dtmfQueue = DtmfQueue(callClient: callClient)
    }
    
    /// Answers an incoming call. Only applies to incoming calls.
    ///
    /// - parameter option: Media option for call: audio-only, audio+video etc. If it contains video, need to specify render view for video.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    open func answer(option: MediaOption, completionHandler: CompletionHandler?) {
        createCallConnection(mediaOption: option, completionHandler: completionHandler) { localMediaInfo, callCreationCompletion in
            self.callClient.joinExistingCall(callUrl: self.url, deviceUrl: self.deviceUrl, localMediaInfo: localMediaInfo, completionHandler: callCreationCompletion)
        }
    }
    
    func dial(address: String, option: MediaOption, completionHandler: CompletionHandler?) {
        to = address
        createCallConnection(mediaOption: option, completionHandler: completionHandler) { localMediaInfo, callCreationCompletion in
            self.callClient.createCall(toAddress: address, deviceUrl: self.deviceUrl, localMediaInfo: localMediaInfo, completionHandler: callCreationCompletion)
        }
    }
    
    private func createCallConnection(mediaOption: MediaOption, completionHandler: CompletionHandler?, callCreationAction: @escaping (MediaInfo, @escaping (ServiceResponse<CallInfo>) -> Void) -> Void) {
        verifyLicenseFor(mediaOption: mediaOption) { verified in
            if verified {
                self.mediaSession.prepare(mediaOption)
                let localMediaInfo = self.localMediaInformation(localSdp: self.mediaSession.getLocalSdp())
                callCreationAction(localMediaInfo) { response in
                    self.onJoinCallCompleted(response, completionHandler: completionHandler)
                }
            } else {
                completionHandler?(false)
            }
        }
    }
    
    private func verifyLicenseFor(mediaOption: MediaOption, completionHandler: @escaping CompletionHandler) {
        guard mediaOption.hasVideo else {
            completionHandler(true)
            return
        }
        callManager.requestVideoCodecActivation(completionHandler: completionHandler)
    }
    
    private func onJoinCallCompleted(_ response: ServiceResponse<CallInfo>, completionHandler: CompletionHandler?) {
        switch response.result {
        case .success(let value):
            update(callInfo: value)
            
            if let remoteSdp = selfMediaConnection?.remoteSdp?.sdp {
                self.mediaSession.setRemoteSdp(remoteSdp)
            } else {
                Logger.error("Failure: remoteSdp is nil")
            }
            self.mediaSession.startMedia()
            callManager.addCallWith(url: self.url, call: self)
            from = info?.hostEmail
            
            Logger.info("Success: join call")
            completionHandler?(true)
            
        case .failure(let error):
            self.mediaSession.stopMedia()
            Logger.error("Failure", error: error)
            completionHandler?(false)
        }
    }
    
    /// Disconnects the active call. Applies to both incoming and outgoing calls.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    open func hangup(_ completionHandler: CompletionHandler?) {
        guard let selfParticipantUrl = selfParticipantUrl else {
            Logger.error("Failure: Missing self participant URL")
            completionHandler?(false)
            return
        }
        mediaSession.stopMedia()
        
        callClient.leave(participantUrl: selfParticipantUrl, deviceUrl: deviceUrl) { response in
            switch response.result {
            case .success(let callInfo):
                self.update(callInfo: callInfo)
                Logger.info("Success: leave call")
                completionHandler?(true)
            case .failure(let error):
                Logger.error("Failure", error: error)
                completionHandler?(false)
            }
        }
    }
    
    /// Rejects an incoming call. Only applies to incoming calls.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    open func reject(_ completionHandler: CompletionHandler?) {
        guard let callUrl = info?.callUrl else {
            Logger.error("Failure: Missing call URL")
            completionHandler?(false)
            return
        }
        mediaSession.stopMedia()
        
        callClient.decline(callUrl: callUrl, deviceUrl: deviceUrl) { response in
            switch response.result {
            case .success:
                Logger.info("Success: reject call")
                completionHandler?(true)
            case .failure(let error):
                Logger.error("Failure", error: error)
                completionHandler?(false)
            }
        }
    }
    
    /// Sends DTMF events to remote destination.
    ///
    /// - parameter dtmf: Valid DTMF events. 0-9, *, #, and A-D.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    open func send(dtmf: String, completionHandler: CompletionHandler?) {
        guard let selfParticipantUrl = selfParticipantUrl else {
            completionHandler?(false)
            Logger.error("Failure: Missing self participant URL")
            return
        }

        if sendingDTMFEnabled {
            dtmfQueue.push(participantUrl: selfParticipantUrl, deviceUrl: deviceUrl, event: dtmf, completionHandler: completionHandler)
        } else {
            completionHandler?(false)
        }
    }
    
    /// If sending video then stop sending video. If not sending video then start sending video.
    ///
    /// - note: This function is expected to run on main thread.
    open func toggleSendingVideo() {
        mediaSession.toggleSendingVideo()
    }
    
    /// If receiving video then stop receiving video. If not receiving video then start receiving video.
    ///
    /// - note: This function is expected to run on main thread.
    open func toggleReceivingVideo() {
        mediaSession.toggleReceivingVideo()
    }
    
    /// If sending audio then stop sending audio. If not sending audio then start sending audio.
    ///
    /// - note: This function is expected to run on main thread.
    open func toggleSendingAudio() {
        mediaSession.toggleSendingAudio()
    }
    
    /// If receiving audio then stop receiving audio. If not receiving audio then start receiving audio.
    ///
    /// - note: This function is expected to run on main thread.
    open func toggleReceivingAudio() {
        mediaSession.toggleReceivingAudio()
    }
    
    /// Toggle camera facing mode between front camera and back camera.
    ///
    /// - note: This function is expected to run on main thread.
    open func toggleFacingMode() {
        mediaSession.toggleFacingMode()
    }
    
    /// Toggle loud speaker.
    ///
    /// - note: This function is expected to run on main thread.
    open func toggleLoudSpeaker() {
        mediaSession.toggleLoudSpeaker()
    }
    
    /// Send feed back to Spark.
    ///
    /// - parameter rating: Rating between 1 and 5.
    /// - parameter comments: User comments.
    /// - parameter includeLogs: True if to include logs, False as not.
    /// - returns: Void
    /// - note: This function is expected to run on main thread.
    open func sendFeedbackWith(rating: Int, comments: String? = nil, includeLogs: Bool = false) {
        guard let info = info else {
            Logger.error("Failure: Missing call info for feedback")
            return
        }

        let feedback = Feedback(rating: rating, comments: comments, includeLogs: includeLogs)
        callMetrics.submit(feedback: feedback, callInfo: info, deviceUrl: deviceUrl)
    }
    
    private var selfMediaConnection: MediaConnection? {
        return info?.selfDevices.filter({$0.url == deviceUrl.absoluteString}).first?.mediaConnections?.first
    }
    
    func updateMedia(sendingAudio: Bool, sendingVideo: Bool) {
        guard let mediaUrl = info?.selfMediaUrl, let localSdpString = selfMediaConnection?.localSdp?.sdp else {
            return
        }

        let audioMuted = !sendingAudio
        let videoMuted = !sendingVideo

        let localMediaInfo = localMediaInformation(localSdp: localSdpString, audioMuted: audioMuted, videoMuted: videoMuted)
        callClient.updateMedia(mediaUrl, deviceUrl: deviceUrl, localMediaInfo: localMediaInfo) { response in
            switch response.result {
            case .success(let value):
                self.update(callInfo: value)
                Logger.info("Success: update media")
            case .failure(let error):
                Logger.error("Failure", error: error)
            }
        }
    }


    func update(callInfo newInfo: CallInfo) {
        guard let oldInfo = info, let oldSequence = oldInfo.sequence else {
            self.info = newInfo
            state.update(callInfo: newInfo, for: self)
            notifyVideoChanged()
            notifyAudioChanged()
            callNotificationCenter.notifyEnableDTMFChanged(self)
            return
        }

        let newSequence = newInfo.sequence!
        let result = CallInfoSequence.overwrite(oldValue: oldSequence, newValue: newSequence)

        switch (result) {
        case .true:
            self.info = newInfo
            state.update(callInfo: newInfo, for: self)

            if (newInfo.remoteVideoMuted != oldInfo.remoteVideoMuted) {
                notifyVideoChanged()
            }

            if (newInfo.remoteAudioMuted != oldInfo.remoteAudioMuted) {
                notifyAudioChanged()
            }

            if (newInfo.enableDTMF != oldInfo.enableDTMF) {
                callNotificationCenter.notifyEnableDTMFChanged(self)
            }
        case .deSync:
            fetchCallInfo()
        default:
            break
        }
    }
    
    func removeFromCallManager() {
        callManager.removeCallWith(url: url)
    }
    
    func isMediaSessionAssociated(_ session: MediaSession) -> Bool {
        return mediaSession.isMediaSessionAssociated(session)
    }

    private func notifyVideoChanged() {
        let videoChangeType = (info?.remoteVideoMuted ?? false) ? RemoteMediaChangeType.remoteVideoMuted : RemoteMediaChangeType.remoteVideoUnmuted
        callNotificationCenter.notifyRemoteMediaChanged(self, mediaUpdatedType: videoChangeType)
    }

    private func notifyAudioChanged() {
        let audioChangeType = (info?.remoteAudioMuted ?? false) ? RemoteMediaChangeType.remoteAudioMuted : RemoteMediaChangeType.remoteAudioUnmuted
        callNotificationCenter.notifyRemoteMediaChanged(self, mediaUpdatedType: audioChangeType)
    }

    private func fetchCallInfo() {
        callClient.fetchCallInfo(url, completionHandler: onFetchCallInfoCompleted)
    }
    
    private func localMediaInformation(localSdp: String, audioMuted: Bool = false, videoMuted: Bool = false) -> MediaInfo {
        return MediaInfo(sdp: localSdp, audioMuted: audioMuted, videoMuted: videoMuted, reachabilities: callManager.localReachabilityInfo)
    }
    
    private func onFetchCallInfoCompleted(_ response: ServiceResponse<CallInfo>) {
        switch response.result {
        case .success(let value):
            update(callInfo: value)
            Logger.info("Success: fetch call info")
        case .failure(let error):
            Logger.error("Failure", error: error)
        }
    }
}


