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

import Foundation
import Wme

class MediaSessionWrapper {
    
    private let mediaSession = MediaSession()
    private var mediaSessionObserver: MediaSessionObserver?
    
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
    var localVideoViewHeight: Int32 {
        return Int32(mediaSession.localVideoViewHeight)
    }
    
    var localVideoViewWidth: Int32 {
        return Int32(mediaSession.localVideoViewWidth)
    }
    
    var remoteVideoViewHeight: Int32 {
        return Int32(mediaSession.remoteVideoViewHeight)
    }
    
    var remoteVideoViewWidth: Int32 {
        return Int32(mediaSession.remoteVideoViewWidth)
    }
    
    // MARK: - Audio & Video
    var audioMuted: Bool {
        get {
            return mediaSession.audioMuted
        }
        set {
            newValue ? mediaSession.muteAudio() : mediaSession.unmuteAudio()
        }
    }
    
    var audioOutputMuted: Bool {
        get {
            return mediaSession.audioOutputMuted
        }
        set {
            newValue ? mediaSession.muteAudioOutput() : mediaSession.unmuteAudioOutput()
        }
    }
    
    var videoMuted: Bool {
        get {
            return mediaSession.videoMuted
        }
        set {
            newValue ? mediaSession.muteVideo() : mediaSession.unmuteVideo()
        }
    }
    
    var videoOutputMuted: Bool {
        get {
            return mediaSession.videoOutputMuted
        }
        set {
            newValue ? mediaSession.muteVideoOutput() : mediaSession.unmuteVideoOutput()
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
    
    // MARK: - lifecycle
    func prepare(option: MediaOption, phone: Phone) {
        if option.hasVideo {
            mediaSession.mediaConstraint = MediaConstraint(constraint: MediaConstraintFlag.audio.rawValue | MediaConstraintFlag.video.rawValue)
            mediaSession.localVideoView = option.localVideoView
            mediaSession.remoteVideoView = option.remoteVideoView
        }
        else {
            mediaSession.mediaConstraint = MediaConstraint(constraint: MediaConstraintFlag.audio.rawValue)
        }
        mediaSession.createMediaConnection()
        mediaSession.setDefaultCamera(phone.defaultFacingMode == Phone.FacingMode.user)
        mediaSession.setDefaultAudioOutput(phone.defaultLoudSpeaker)
    }
    
    func startMedia(call: Call) {
        mediaSessionObserver = MediaSessionObserver(call: call)
        mediaSessionObserver?.startObserving(mediaSession)
        mediaSession.connectToCloud()
    }
    
    func stopMedia() {
        mediaSessionObserver?.stopObserving()
        mediaSession.disconnectFromCloud()
    }
}
