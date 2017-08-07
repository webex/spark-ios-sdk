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
import AVFoundation
import Wme

class MediaSessionObserver: NotificationObserver {
    
    //change retain to weak,it cause retain cycle(Call - MediaSessionWrapper - MediaSessionObserver)
    private weak var call: Call?
    
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
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.cameraSwitched)
            }
        }
    }
    
    @objc private func onMediaEngineDidChangeAudioRoute(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.spearkerSwitched)
            }
        }
    }
    
    @objc private func onMediaEngineDidChangeLocalViewSize(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.localVideoViewSize)
            }
        }
    }
    
    @objc private func onMediaEngineDidChangeRemoteViewSize(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.remoteVideoViewSize)
            }
        }
    }
    
    @objc private func onMediaEngineDidMuteVideo(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.updateMedia(sendingAudio: retainCall.sendingAudio, sendingVideo: false)
                retainCall.onMediaChanged?(Call.MediaChangedEvent.sendingVideo(false))
            }
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideo(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.updateMedia(sendingAudio: retainCall.sendingAudio, sendingVideo: true)
                retainCall.onMediaChanged?(Call.MediaChangedEvent.sendingVideo(true))
            }
        }
    }
    
    @objc private func onMediaEngineDidMuteVideoOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.receivingVideo(false))
            }
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideoOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.receivingVideo(true))
            }
        }
    }
    
    @objc private func onMediaEngineDidMuteAudio(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.updateMedia(sendingAudio: false, sendingVideo: retainCall.sendingVideo)
                retainCall.onMediaChanged?(Call.MediaChangedEvent.sendingAudio(false))
            }
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudio(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.updateMedia(sendingAudio: true, sendingVideo: retainCall.sendingVideo)
                retainCall.onMediaChanged?(Call.MediaChangedEvent.sendingAudio(true))
            }
        }
    }
    
    @objc private func onMediaEngineDidMuteAudioOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.receivingAudio(false))
            }
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudioOutput(_ notification: Notification) {
        DispatchQueue.main.async {
            if let retainCall = self.call {
                retainCall.onMediaChanged?(Call.MediaChangedEvent.receivingAudio(true))
            }
        }
    }
}
