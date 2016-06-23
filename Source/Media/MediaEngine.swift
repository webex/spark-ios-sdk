// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    
    var audioOutputMuted: Bool {
        return mediaEngine.activeMediaSession.audioOutputMuted
    }
    
    var videoMuted: Bool {
        return mediaEngine.activeMediaSession.videoMuted
    }
    
    var videoOutputMuted: Bool {
        return mediaEngine.activeMediaSession.videoOutputMuted
    }

    init() {
        WmeLogManager.sharedInstance().addLogger(MediaEngineCustomLogger())
    }
    
    func start(mediaSession: MediaSession) {
        self.mediaSession = mediaSession
        
        stopMedia()

        mediaEngine.configureAudioSession()
        applyDefaultMediaSettings()
        
        mediaEngine.addMediaSession(mediaSession)
        
        if mediaEngineObserver == nil {
            mediaEngineObserver = MediaEngineObserver()
        }
        mediaEngineObserver.startObserving()
    }
    
    func getLocalSdp(mediaSession: MediaSession) -> String {
        mediaEngine.createSdpOffer(mediaSession)
        return mediaEngine.localWmeSdpOffer
    }
    
    func setRemoteSdp(sdp: String) {
        mediaEngine.receiveSdpAnswer(mediaSession, sdp: sdp, featureToggles: [:])
    }
    
    func toggleSendingVideo() {
        if !isMediaStarted() {
            return
        }
        
        if videoMuted {
            mediaEngine.unmuteVideo()
        } else {
            mediaEngine.muteVideo()
        }
    }
    
    func toggleReceivingVideo() {
        if !isMediaStarted() {
            return
        }
        
        if videoOutputMuted {
            mediaEngine.unmuteVideoOutput()
        } else {
            mediaEngine.muteVideoOutput()
        }
    }
    
    func toggleSendingAudio() {
        if !isMediaStarted() {
            return
        }
        
        if audioMuted {
            mediaEngine.unmuteAudio()
        } else {
            mediaEngine.muteAudio()
        }
    }
    
    func toggleReceivingAudio() {
        if !isMediaStarted() {
            return
        }
        
        if audioOutputMuted {
            mediaEngine.unmuteAudioOutput()
        } else {
            mediaEngine.muteAudioOutput()
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

    func performReachabilityCheck(clusterInfo: [NSObject : AnyObject], completionHandler: ReachabilityCheckHandler) {
        mediaEngine.performStunReachabilityCheck(clusterInfo) {
            result in
            completionHandler(result)
        }
    }
    
    func clearReachabilityData() {
        mediaEngine.clearReachabilityData()
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
        let isFront = Phone.sharedInstance.defaultFacingMode == Call.FacingMode.User
        mediaEngine.setDefaultVideoCamera(isFront)
        
    }
    
    private func setDefaultAudioRoute() {
        mediaEngine.switchSpeaker(Phone.sharedInstance.defaultLoudSpeaker)
    }
}
