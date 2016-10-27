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
    private let callNotificationCenter = CallNotificationCenter.sharedInstance
    
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
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyFacingModeChanged(call, facingMode: call.facingMode)
        }
    }
    
    @objc private func onMediaEngineDidChangeLocalViewSize(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyLocalViewSizeChanged(call, height: call.localVideoViewHeight, width: call.localVideoViewWidth)
        }
    }
    
    @objc private func onMediaEngineDidChangeRemoteViewSize(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteViewSizeChanged(call, height: call.remoteVideoViewHeight, width: call.remoteVideoViewWidth)
        }
    }
    
    @objc private func onMediaEngineDidMuteVideo(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            call.updateMedia(sendingAudio: call.sendingAudio, sendingVideo: false)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.localVideoMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideo(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
			call.updateMedia(sendingAudio: call.sendingAudio, sendingVideo: true)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.localVideoUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidMuteVideoOutput(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.remoteVideoOutputMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideoOutput(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.remoteVideoOutputUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidMuteAudio(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            call.updateMedia(sendingAudio: false, sendingVideo: call.sendingVideo)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.localAudioMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudio(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            call.updateMedia(sendingAudio: true, sendingVideo: call.sendingVideo)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.localAudioUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidMuteAudioOutput(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.remoteAudioOutputMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudioOutput(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.remoteAudioOutputUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidChangeAudioRoute(_ notification: Notification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyLoudSpeakerChanged(call, isLoudSpeakerSelected: call.loudSpeaker)
        }
    }
    
    private func getCallFromNotification(_ notification: Notification) -> Call? {
        if let session = notification.object as? MediaSession {
			return CallManager.sharedInstance.findCallBy(mediaSession: session)
        }
        return nil
    }
}
