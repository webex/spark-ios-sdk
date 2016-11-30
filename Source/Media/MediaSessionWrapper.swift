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

import Foundation
import Wme

class MediaSessionWrapper {
    private let mediaSession = MediaSession()
    private let mediaSessionObserver: MediaSessionObserver
    
    init(callManager: CallManager) {
        mediaSessionObserver = MediaSessionObserver(callManager: callManager)
    }
    
    func isMediaSessionAssociated(_ session: MediaSession) -> Bool {
        return session == mediaSession
    }
    
    // MARK: - SDP
    func getLocalSdp() -> String {
        mediaSession.createLocalSdpOffer()
        return mediaSession.localSdpOffer
    }
    
    func setRemoteSdp(_ sdp: String) {
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
    func prepare(_ mediaOption: MediaOption) {
        var constraint: MediaConstraint!
        var localView: MediaRenderView? = nil
        var remoteView: MediaRenderView? = nil

        switch (mediaOption) {
        case .audioOnly:
            constraint = MediaConstraint(constraint: MediaConstraintFlag.audio.rawValue)
        case .audioVideo(let local, let remote):
            constraint = MediaConstraint(constraint: MediaConstraintFlag.audio.rawValue | MediaConstraintFlag.video.rawValue)
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
