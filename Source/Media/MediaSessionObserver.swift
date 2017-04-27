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
import AVFoundation
import Wme

class MediaSessionObserver: NotificationObserver {
    
    private let call: Call
    
    init(call: Call) {
        self.call = call
    }
    
    override func notificationMapping() -> [(Notification.Name, Selector)] {
        return [
            (.MediaEngineDidSwitchCameras,         #selector(onMediaEngineDidSwitchCameras(_:))),
            (.MediaEngineDidChangeLocalViewSize,   #selector(onMediaEngineDidChangeLocalViewSize(_:))),
            (.MediaEngineDidChangeRemoteViewSize,  #selector(onMediaEngineDidChangeRemoteViewSize(_:))),
            (.MediaEngineDidMuteVideo,             #selector(onMediaEngineDidMuteVideo(_:))),
            (.MediaEngineDidUnMuteVideo,           #selector(onMediaEngineDidUnMuteVideo(_:))),
            (.MediaEngineDidMuteVideoOutput,       #selector(onMediaEngineDidMuteVideoOutput(_:))),
            (.MediaEngineDidUnMuteVideoOutput,     #selector(onMediaEngineDidUnMuteVideoOutput(_:))),
            (.MediaEngineDidMuteAudio,             #selector(onMediaEngineDidMuteAudio(_:))),
            (.MediaEngineDidUnMuteAudio,           #selector(onMediaEngineDidUnMuteAudio(_:))),
            (.MediaEngineDidMuteAudioOutput,       #selector(onMediaEngineDidMuteAudioOutput(_:))),
            (.MediaEngineDidUnMuteAudioOutput,     #selector(onMediaEngineDidUnMuteAudioOutput(_:))),
            (.MediaEngineDidChangeAudioRoute,      #selector(onMediaEngineDidChangeAudioRoute(_:)))]
    }
    
    @objc private func onMediaEngineDidSwitchCameras(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.cameraSwitched)
        }
    }
    
    @objc private func onMediaEngineDidChangeAudioRoute(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.spearkerSwitched)
        }
    }
    
    @objc private func onMediaEngineDidChangeLocalViewSize(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.localVideoViewSize)
        }
    }
    
    @objc private func onMediaEngineDidChangeRemoteViewSize(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.remoteVideoViewSize)
        }
    }
    
    @objc private func onMediaEngineDidMuteVideo(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.updateMedia(sendingAudio: self.call.sendingAudio, sendingVideo: false)
            self.call.onMediaChanged?(Call.MediaChangeType.sendingVideo(false))
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideo(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.updateMedia(sendingAudio: self.call.sendingAudio, sendingVideo: true)
            self.call.onMediaChanged?(Call.MediaChangeType.sendingVideo(true))
        }
    }
    
    @objc private func onMediaEngineDidMuteVideoOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.receivingVideo(false))
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideoOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.receivingVideo(true))
        }
    }
    
    @objc private func onMediaEngineDidMuteAudio(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.updateMedia(sendingAudio: false, sendingVideo: self.call.sendingVideo)
            self.call.onMediaChanged?(Call.MediaChangeType.sendingAudio(false))
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudio(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.updateMedia(sendingAudio: true, sendingVideo: self.call.sendingVideo)
            self.call.onMediaChanged?(Call.MediaChangeType.sendingAudio(true))
        }
    }
    
    @objc private func onMediaEngineDidMuteAudioOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.receivingAudio(false))
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudioOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            self.call.onMediaChanged?(Call.MediaChangeType.receivingAudio(true))
        }
    }
}
