//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import ObjectMapper

/// Represents a Spark call.
public class Call {
    
    /// Completion handler for a call operation.
    public typealias CompletionHandler = Bool -> Void
    
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
    public var status: Status {
        return state.status
    }

    /// The intended recipient of the call. 
    /// For an outgoing call this is the same as the address specified in dial. 
    /// For an incoming call this is the identity of the authenticated user.
    public var to: String?
    
    /// The receiver of the call. 
    /// For an outgoing call this is the identity of the authenticated user.
    /// For an incoming call this is the email address / phone number / SIP address of the caller.
    public var from: String?
    
    /// True if client is sending audio (not muted).
    public var sendingAudio: Bool {
        return !mediaSession.audioMuted
    }
    
    /// True if client is sending video (not muted).
    public var sendingVideo: Bool {
        return !mediaSession.videoMuted
    }
    
    /// True if loud speaker is selected as the output device for this call.
    public var loudSpeaker: Bool {
        return mediaEngine.isSpeaker()
    }
    
    /// Camera facing mode selected for this call.
    public var facingMode: FacingMode {
        return mediaEngine.isFrontCamera() ? .User : .Environment
    }
    
    var info: CallInfo?
    var state: CallState!
    var url: String { return (info?.callUrl)! }
    
    private let mediaEngine = MediaEngine.sharedInstance
    
    // TODO: need to consider MediaSession management
    private let mediaSession = MediaSession()
    private let deviceUrl = DeviceService.sharedInstance.deviceUrl
    
    init() {
        state = CallStateIdle(self)
    }
    
    init(_ info: CallInfo) {
        self.info = info
        to = info.selfEmail
        from = info.hostEmail
        
        state = CallStateIncoming(self)
    }
    
    /// Answers an incoming call. Only applies to incoming calls.
    ///
    /// - parameter renderView: Render view when call get connected.
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    public func answer(renderView: RenderView, completionHandler: CompletionHandler?) {
        mediaEngine.start(self.mediaSession)
        setupMediaView(renderView.local, renderView.remote)
        
        let localInfo = self.createLocalInfo(self.mediaEngine.getLocalSdp())
        CallClient().join(self.url, localInfo: localInfo) {
            self.onJoinCallCompleted($0, completionHandler: completionHandler)
        }
    }
    
    /// Disconnects the active call. Applies to both incoming and outgoing calls.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    public func hangup(completionHandler: CompletionHandler?) {
        mediaEngine.stopMedia()
        
        let participantUrl = info?.selfParticipantUrl
        CallClient().leave(participantUrl!, deviceUrl: deviceUrl!) {
            switch $0.result {
            case .Success(let value):
                self.updateCallInfo(value)
                print("Success: leave call")
                completionHandler?(true)
            case .Failure(let error):
                print("Failure: \(error.localizedFailureReason)")
                assertionFailure("Failure: \(error.localizedFailureReason)")
                completionHandler?(false)
            }
        }
    }
    
    /// Rejects an incoming call. Only applies to incoming calls.
    ///
    /// - parameter completionHandler: A closure to be executed once the action is completed. True means success, False means failure.
    /// - returns: Void
    public func reject(completionHandler: CompletionHandler?) {
        mediaEngine.stopMedia()
        
        let callUrl = info?.callUrl
        CallClient().decline(callUrl!, deviceUrl: deviceUrl!) {
            switch $0.result {
            case .Success:
                print("Success: reject call")
                completionHandler?(true)
            case .Failure(let error):
                print("Failure: \(error.localizedFailureReason)")
                assertionFailure("Failure: \(error.localizedFailureReason)")
                completionHandler?(false)
            }
        }
    }
    
    /// If sending video then stop sending video. If not sending sending video then start sending video.
    public func toggleSendingVideo() {
        mediaEngine.toggleVideo()
    }
    
    /// If sending audio then stop sending audio. If not sending sending audio then start sending audio.
    public func toggleSendingAudio() {
        mediaEngine.toggleAudio()
    }
    
    /// Toggle camera facing mode between front camera and back camera.
    public func toggleFacingMode() {
        mediaEngine.toggleFacingMode()
    }
    
    /// Toggle loud speaker.
    ///
    /// - parameter isSpeaker: True if use loud speaker as the output device, False as not.
    /// - returns: Void
    public func toggleLoudSpeaker(isSpeaker: Bool) {
        mediaEngine.toggleLoudSpeaker(isSpeaker)
    }
    
    /// Send feed back to Spark.
    ///
    /// - parameter rating: Rating between 1 and 5.
    /// - parameter comments: User comments.
    /// - parameter includeLogs: True if to include logs, False as not.
    /// - returns: Void
    public func sendFeedback(rating: Int, comments: String? = nil, includeLogs: Bool = false) {
        let feedback = Feedback(rating: rating, comments: comments, includeLogs: includeLogs)
        CallMetrics.sharedInstance.submitFeedback(feedback, callInfo: info!)
    }
    
    func dial(address: String, renderView: RenderView, completionHandler: CompletionHandler?) {
        mediaEngine.start(mediaSession)
        setupMediaView(renderView.local, renderView.remote)
        
        let localInfo = createLocalInfo(mediaEngine.getLocalSdp())
        localInfo.updateValue(["address": address], forKey: "invitee")
        CallClient().join(localInfo) {
            self.onJoinCallCompleted($0, completionHandler: completionHandler)
        }
        
        to = address
    }
    
    func updateMedia(sendingAudio: Bool, _ sendingVideo: Bool){
        let mediaUrl = info?.selfMediaUrl
        assert(mediaUrl != nil, "mediaUrl is nil")
        
        let mediaInfo = info?.selfMediaInfo
        assert(mediaInfo != nil, "mediaInfo is nil")
        
        let audioMuted = !sendingAudio
        let videoMuted = !sendingVideo
        
        let localInfo = createLocalInfo((mediaInfo?.sdp)!, audioMuted: audioMuted, videoMuted: videoMuted)
        CallClient().updateMedia(mediaUrl!, localInfo: localInfo) {
            switch $0.result {
            case .Success(let value):
                self.updateCallInfo(value)
                print("Success: update media")
            case .Failure(let error):
                print("Failure: \(error.localizedFailureReason)")
                assertionFailure("Failure: \(error.localizedFailureReason)")
            }
        }
    }
    
    func updateCallInfo(info: CallInfo) {
        if self.info == nil {
            setCallInfo(info)
            state.update()
            return
        }
        
        let result = CallInfoSequence.overwrite(oldValue: self.info!.sequence!, newValue: info.sequence!)
        switch (result) {
        case .True:
            setCallInfo(info)
            state.update()
        case .DeSync:
            fetchCallInfo()
        default:
            break
        }
    }
    
    private func setupMediaView(local: MediaRenderView, _ remote: MediaRenderView) {
        mediaSession.localPreviewView = local
        mediaSession.renderView = remote
    }
    
    private func fetchCallInfo() {
        CallClient().fetchCallInfo(url, completionHandler: onFetchCallInfoCompleted)
    }
    
    private func setCallInfo(info: CallInfo) {
        self.info = info
    }
    
    private func createLocalInfo(localSdp: String, audioMuted: Bool = false, videoMuted: Bool = false) -> HttpParameters {
        let mediaInfo = MediaInfo(sdp: localSdp, audioMuted: audioMuted, videoMuted: videoMuted)
        let mediaInfoJSON = Mapper().toJSONString(mediaInfo, prettyPrint: true)
        let localMedias = [["type": "SDP", "localSdp": mediaInfoJSON!]]
        
        return HttpParameters(["deviceUrl": deviceUrl!, "localMedias": localMedias])
    }
    
    private func onJoinCallCompleted(response: ServiceResponse<CallInfo>, completionHandler: CompletionHandler?) {
        switch response.result {
        case .Success(let value):
            updateCallInfo(value)
            if let remoteSdp = self.info?.remoteSdp {
                self.mediaEngine.setRemoteSdp(remoteSdp)
            } else {
                assertionFailure("Failure - remoteSdp is nil")
            }
            self.mediaEngine.startMedia()
            CallManager.sharedInstance.addCall(self.url, call: self)
            from = info?.hostEmail
            
            print("Success: join call")
            completionHandler?(true)
            
        case .Failure(let error):
            print("Failure: \(error.localizedFailureReason)")
            assertionFailure("Failure: \(error.localizedFailureReason)")
            completionHandler?(false)
        }
    }
    
    private func onFetchCallInfoCompleted(response: ServiceResponse<CallInfo>) {
        switch response.result {
        case .Success(let value):
            updateCallInfo(value)
            print("Success: fetch call info")
        case .Failure(let error):
            print("Failure: \(error.localizedFailureReason)")
            assertionFailure("Failure: \(error.localizedFailureReason)")
        }
    }
}


