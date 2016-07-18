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

class MediaSessionWrapper {
    private let mediaSession = MediaSession()
    private let mediaSessionObserver = MediaSessionObserver()
    
    
    func isMediaSessionAssociated(session: MediaSession) -> Bool {
        return session == mediaSession
    }
    
    // MARK: - SDP
    func getLocalSdp() -> String {
        mediaSession.createLocalSdpOffer()
        return mediaSession.localSdpOffer
    }
    
    func setRemoteSdp(sdp: String) {
        mediaSession.receiveRemoteSdpAnswer(sdp)
    }
    
    var hasAudio: Bool {
        return mediaSession.mediaConstraint.hasAudio
    }

    var hasVideo: Bool {
        return mediaSession.mediaConstraint.hasVideo
    }
    
    var hasScreenShare: Bool {
        return mediaSession.mediaConstraint.hasScreenShare
    }
    
    // MARK: - Local View & Remote View
    var localVideoViewHeight: UInt32 {
        return mediaSession.localVideoViewHeight
    }
    
    var localVideoViewWidth: UInt32 {
        return mediaSession.localVideoViewWidth
    }
    
    var remoteVideoViewHeight: UInt32 {
        return mediaSession.remoteVideoViewHeight
    }
    
    var remoteVideoViewWidth: UInt32 {
        return mediaSession.remoteVideoViewWidth
    }

    // MARK: - Audio & Video
    var audioMuted: Bool {
        return mediaSession.audioMuted
    }
    
    var audioOutputMuted: Bool {
        return mediaSession.audioOutputMuted
    }
    
    var videoMuted: Bool {
        return mediaSession.videoMuted
    }
    
    var videoOutputMuted: Bool {
        return mediaSession.videoOutputMuted
    }

    func toggleSendingVideo() {
        if videoMuted {
            mediaSession.unmuteVideo()
        } else {
            mediaSession.muteVideo()
        }
    }
    
    func toggleReceivingVideo() {
        if videoOutputMuted {
            mediaSession.unmuteVideoOutput()
        } else {
            mediaSession.muteVideoOutput()
        }
    }
    
    func toggleSendingAudio() {
        if audioMuted {
            mediaSession.unmuteAudio()
        } else {
            mediaSession.muteAudio()
        }
    }
    
    func toggleReceivingAudio() {
        if audioOutputMuted {
            mediaSession.unmuteAudioOutput()
        } else {
            mediaSession.muteAudioOutput()
        }
    }
    
    // MARK: - Camera
    func toggleFacingMode() {
        mediaSession.toggleCamera()
    }
    
    func isFrontCameraSelected() -> Bool {
        return mediaSession.isFrontCameraSelected()
    }
    
    // MARK: - Loud Speaker
    func toggleLoudSpeaker() {
        mediaSession.toggleSpeaker()
    }
    
    func isSpeakerSelected() -> Bool {
        return mediaSession.isSpeakerSelected()
    }
    
    // MARK: - Default settings
    private func applyDefaultMediaSettings() {
        setDefaultFacingMode()
        setDefaultAudioOutput()
    }
    
    private func setDefaultFacingMode() {
        let isFront = Phone.sharedInstance.defaultFacingMode == Call.FacingMode.User
        mediaSession.setDefaultCamera(isFront)
    }
    
    private func setDefaultAudioOutput() {
        mediaSession.setDefaultAudioOutput(Phone.sharedInstance.defaultLoudSpeaker)
    }
    
    // MARK: - lifecycle
    func prepare(mediaOption: MediaOption) {
        var constraint: MediaConstraint!
        var localView: MediaRenderView? = nil
        var remoteView: MediaRenderView? = nil

        switch (mediaOption) {
        case .AudioOnly:
            constraint = MediaConstraint(constraint: MediaConstraintFlag.Audio.rawValue)
        case .AudioVideo(let local, let remote):
            constraint = MediaConstraint(constraint: MediaConstraintFlag.Audio.rawValue | MediaConstraintFlag.Video.rawValue)
            localView = local
            remoteView = remote
        }

        mediaSession.mediaConstraint = constraint
        mediaSession.localVideoView = localView
        mediaSession.remoteVideoView = remoteView
        
        mediaSessionObserver.startObserving(mediaSession)
        mediaSession.createMediaConnection()

        applyDefaultMediaSettings()
    }
    
    func startMedia() {
        mediaSession.connectToCloud()
    }
    
    func stopMedia() {
        mediaSessionObserver.stopObserving()
        mediaSession.disconnectFromCloud()
    }
}
