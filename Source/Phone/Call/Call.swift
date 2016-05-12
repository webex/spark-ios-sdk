//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import ObjectMapper

public class Call {
    
    public typealias CompletionHandler = Bool -> Void
    
    public enum FacingMode: String {
        case User
        case Environment
    }
    
    public enum Status: String {
        case Initiated
        case Ringing
        case Incoming
        case Connected
        case Disconnected
    }
    
    public var status: Status { return state.status }
    // Callee party
    public var to: String?
    // Caller party
    public var from: String?
    public var sendingAudio: Bool { return !mediaSession.audioMuted }
    public var sendingVideo: Bool { return !mediaSession.videoMuted }
    public var loudSpeaker: Bool { return mediaEngine.isSpeaker() }
    public var facingMode: FacingMode {
        let isFront =  mediaEngine.isFrontCamera()
        if isFront {
            return FacingMode.User
        } else {
            return FacingMode.Environment
        }
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
    
    public func answer(renderView: RenderView, completionHandler: CompletionHandler?) {
        mediaEngine.start(self.mediaSession)
        setupMediaView(renderView.local, renderView.remote)
        
        let localInfo = self.createLocalInfo(self.mediaEngine.getLocalSdp())
        CallClient().join(self.url, localInfo: localInfo) {
            self.onJoinCallCompleted($0, completionHandler: completionHandler)
        }
    }
    
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
    
    public func toggleVideo() {
        mediaEngine.toggleVideo()
    }
    
    public func toggleAudio() {
        mediaEngine.toggleAudio()
    }
    
    public func toggleFacingMode() {
        mediaEngine.toggleFacingMode()
    }
    
    public func toggleLoudSpeaker(isSpeaker: Bool) {
        mediaEngine.toggleLoudSpeaker(isSpeaker)
    }
    
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


