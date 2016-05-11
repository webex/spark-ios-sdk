//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import Wme

class MediaEngine {
    
    static let sharedInstance = MediaEngine()
    
    var WMEVersion: String {
        return Wme.MediaEngine.WMEVersion()
    }
    
    private var mediaSession: Wme.MediaSession?
    private let mediaEngine = Wme.MediaEngine.sharedInstance()
    private var mediaEngineObserver: MediaEngineObserver! = nil
    
    var audioMuted: Bool {
        return mediaEngine.activeMediaSession.audioMuted
    }
    
    var videoMuted: Bool {
        return mediaEngine.activeMediaSession.videoMuted
    }
    
    func start(mediaSession: MediaSession) {
        self.mediaSession = mediaSession
        
        stopMedia()
        
        mediaEngine.start()
        mediaEngine.configureAudioSession()
        applyDefaultMediaSettings()
        
        mediaEngine.addMediaSession(mediaSession)
        
        if mediaEngineObserver == nil {
            mediaEngineObserver = MediaEngineObserver()
        }
        mediaEngineObserver.startObserving()
    }
    
    func getLocalSdp() -> String {
        
        mediaEngine.createSdpOffer()
        return mediaEngine.localWmeSdpOffer
    }
    
    func setRemoteSdp(sdp: String) {
        mediaEngine.receiveSdpAnswer(mediaSession, sdp: sdp, featureToggles: [:])
    }
    
    func toggleVideo() {
        if videoMuted {
            mediaEngine.unMuteVideo()
        } else {
            mediaEngine.muteVideo()
        }
    }
    
    func toggleAudio() {
        if audioMuted {
            mediaEngine.unmuteAudio()
        } else {
            mediaEngine.muteAudio()
        }
    }
    
    func startMedia() {
        if isMediaStarted() {
            return
        }
        
        mediaEngine.connectToCloudMediaEngineWithMediaSession(mediaSession)
    }
    
    func stopMedia() {
        guard isMediaStarted() else {
            return
        }
        mediaEngineObserver.stopObserving()
        
        mediaEngine.removeMediaSession(mediaSession)
        mediaEngine.endMediaSession(mediaSession)
    }
    
    func toggleFacingMode() {
        mediaEngine.switchCameras()
    }
    
    func isFrontCamera() -> Bool {
        return mediaEngine.isFrontCamera()
    }
    
    func toggleLoudSpeaker(isSpeaker: Bool) {
        mediaEngine.switchSpeaker(isSpeaker)
    }
    
    func isSpeaker() -> Bool {
        return mediaEngine.isSpeaker()
    }
    
    func configureAudioSession() {
        mediaEngine.configureAudioSession()
    }
    
    private func isMediaStarted() -> Bool {
        
        guard mediaEngine.mediaAgentsCreated else {
            return false
        }
        
        if mediaSession == nil {
            return false
        }
        
        if mediaSession!.videoConnectionState != mediaSessionIdle {
            return true
        }
        
        if mediaSession!.audioConnectionState != mediaSessionIdle {
            return true
        }
        
        return false
    }
    
    private func applyDefaultMediaSettings() {
        setDefaultCamera()
        setDefaultAudioRoute()
    }
    
    private func setDefaultCamera() {
        if let defaultFacingMode = UserDefaults.sharedInstance.facingMode {
            let isFront: Bool
            
            if defaultFacingMode == Call.FacingMode.User.rawValue {
                isFront = true
            } else {
                isFront = false
            }
            mediaEngine.setDefaultVideoCamera(isFront)
        }
    }
    
    private func setDefaultAudioRoute() {
        if let isSpeaker = UserDefaults.sharedInstance.loudSpeaker {
            mediaEngine.switchSpeaker(isSpeaker)
        }
    }
}
