//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import ObjectMapper

public class Call {
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
    
    public func answer(completionHandler: ((Bool) -> Void)!) {
        Spark.phone.requestAccessForMedia() { granted in
            
            if !self.state.isAllowedToAnswer() {
                return
            }
            
            if self.info == nil {
                print("Failure - info is invlid")
                assertionFailure("Failure - info is invlid")
                return
            }
            
            if !granted {
                completionHandler(false)
                return
            }
            
            self.mediaEngine.start(self.mediaSession)
            
            let localInfo = self.createLocalInfo(self.mediaEngine.getLocalSdp())
            CallClient().join(self.url, localInfo: localInfo, completionHandler: self.onJoinCallCompleted)
            completionHandler(true)
        }
    }
    
    public func hangup() {
        if !state.isAllowedToHangup() {
            return
        }
        
        if info == nil {
            print("Failure - info is invlid")
            assertionFailure("Failure - info is invlid")
            return
        }
        
        mediaEngine.stopMedia()
        
        let participantUrl = info?.selfParticipantUrl
        CallClient().leave(participantUrl!, deviceUrl: deviceUrl!) {
            (response: ServiceResponse<CallInfo>) in
            switch response.result {
            case .Success(let value):
                self.updateCallInfo(value)
                print("Success: leave call")
            case .Failure(let error):
                print("Failure: \(error.localizedFailureReason)")
                assertionFailure("Failure: \(error.localizedFailureReason)")
                break
            }
        }
    }
    
    public func reject() {
        if !state.isAllowedToReject() {
            return
        }
        
        if info == nil {
            print("Failure - info is invlid")
            assertionFailure("Failure - info is invlid")
            return
        }
        
        mediaEngine.stopMedia()
        
        let callUrl = info?.callUrl
        CallClient().decline(callUrl!, deviceUrl: deviceUrl!) {
            (response: ServiceResponse<AnyObject>) in
            switch response.result {
            case .Success:
                print("Success: reject call")
            case .Failure(let error):
                print("Failure: \(error.localizedFailureReason)")
                assertionFailure("Failure: \(error.localizedFailureReason)")
                break
            }
        }
    }
    
    public func toggleVideo() {
        if state.isAllowedToOperateMedia() {
            mediaEngine.toggleVideo()
        }
    }
    
    public func toggleAudio() {
        if state.isAllowedToOperateMedia() {
            mediaEngine.toggleAudio()
        }
    }
    
    public func toggleFacingMode() {
        if state.isAllowedToOperateMedia() {
            mediaEngine.toggleFacingMode()
        }
    }
    
    public func toggleLoudSpeaker(isSpeaker: Bool) {
        if state.isAllowedToOperateMedia() {
            mediaEngine.toggleLoudSpeaker(isSpeaker)
        }
    }
    
    public func setupMediaView(localView: MediaRenderView, _ remoteView: MediaRenderView) {
        mediaSession.localPreviewView = localView
        mediaSession.renderView = remoteView
    }
    
    public func sendFeedback(rating: Int, comments: String? = nil, includeLogs: Bool = false) {
        if info == nil {
            assertionFailure("Failure: call info is nil")
            return
        }
        
        let feedback = Feedback(rating: rating, comments: comments, includeLogs: includeLogs)
        CallMetrics.sharedInstance.submitFeedback(feedback, callInfo: info!)
    }
    
    func dial(address: String) {
        if !state.isAllowedToDial() {
            return
        }
        
        mediaEngine.start(mediaSession)
        
        let localInfo = createLocalInfo(mediaEngine.getLocalSdp())
        localInfo.updateValue(["address": address], forKey: "invitee")
        CallClient().join(localInfo, completionHandler: onJoinCallCompleted)
        
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
            (response: ServiceResponse<CallInfo>) in
            switch response.result {
            case .Success(let value):
                self.updateCallInfo(value)
                print("Success: update media")
            case .Failure(let error):
                print("Failure: \(error.localizedFailureReason)")
                assertionFailure("Failure: \(error.localizedFailureReason)")
                break
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
    
    private func onJoinCallCompleted(response: ServiceResponse<CallInfo>) {
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
            
        case .Failure(let error):
            print("Failure: \(error.localizedFailureReason)")
            assertionFailure("Failure: \(error.localizedFailureReason)")
            break
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
            break
        }
    }
}


