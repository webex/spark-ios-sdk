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
    
    var videoMuted: Bool {
        return mediaEngine.activeMediaSession.videoMuted
    }
    
    init() {
        WmeLogManager.sharedInstance().addLogger(MediaEngineCustomLogger())
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
        if !isMediaStarted() {
            return
        }
        
        if videoMuted {
            mediaEngine.unMuteVideo()
        } else {
            mediaEngine.muteVideo()
        }
    }
    
    func toggleAudio() {
        if !isMediaStarted() {
            return
        }
        
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
