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
    
    override func getNotificationHandlerMap() -> [String: String] {
        return [
            MediaEngineDidSwitchCamerasNotification:         "onMediaEngineDidSwitchCameras:",
            MediaEngineDidChangeLocalViewSizeNotification:   "onMediaEngineDidChangeLocalViewSize:",
            MediaEngineDidChangeRemoteViewSizeNotification:  "onMediaEngineDidChangeRemoteViewSize:",
            MediaEngineDidMuteVideoNotification:             "onMediaEngineDidMuteVideo:",
            MediaEngineDidUnMuteVideoNotification:           "onMediaEngineDidUnMuteVideo:",
            MediaEngineDidMuteVideoOutputNotification:       "onMediaEngineDidMuteVideoOutput:",
            MediaEngineDidUnMuteVideoOutputNotification:     "onMediaEngineDidUnMuteVideoOutput:",
            MediaEngineDidMuteAudioNotification:             "onMediaEngineDidMuteAudio:",
            MediaEngineDidUnMuteAudioNotification:           "onMediaEngineDidUnMuteAudio:",
            MediaEngineDidMuteAudioOutputNotification:       "onMediaEngineDidMuteAudioOutput:",
            MediaEngineDidUnMuteAudioOutputNotification:     "onMediaEngineDidUnMuteAudioOutput:",
            MediaEngineDidChangeAudioRouteNotification:      "onMediaEngineDidChangeAudioRoute:"]
    }
    
    @objc private func onMediaEngineDidSwitchCameras(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyFacingModeChanged(call, facingMode: call.facingMode)
        }
    }
    
    @objc private func onMediaEngineDidChangeLocalViewSize(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyLocalViewSizeChanged(call, height: call.localVideoViewHeight, width: call.localVideoViewWidth)
        }
    }
    
    @objc private func onMediaEngineDidChangeRemoteViewSize(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteViewSizeChanged(call, height: call.remoteVideoViewHeight, width: call.remoteVideoViewWidth)
        }
    }
    
    @objc private func onMediaEngineDidMuteVideo(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            call.updateMedia(call.sendingAudio, false)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.LocalVideoMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideo(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            call.updateMedia(call.sendingAudio, true)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.LocalVideoUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidMuteVideoOutput(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.RemoteVideoOutputMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideoOutput(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.RemoteVideoOutputUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidMuteAudio(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            call.updateMedia(false, call.sendingVideo)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.LocalAudioMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudio(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            call.updateMedia(true, call.sendingVideo)
            callNotificationCenter.notifyLocalMediaChanged(call, mediaUpdatedType: LocalMediaChangeType.LocalAudioUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidMuteAudioOutput(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.RemoteAudioOutputMuted)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudioOutput(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyRemoteMediaChanged(call, mediaUpdatedType: RemoteMediaChangeType.RemoteAudioOutputUnmuted)
        }
    }
    
    @objc private func onMediaEngineDidChangeAudioRoute(notification: NSNotification) {
        if let call = getCallFromNotification(notification) {
            callNotificationCenter.notifyLoudSpeakerChanged(call, isLoudSpeakerSelected: call.loudSpeaker)
        }
    }
    
    private func getCallFromNotification(notification: NSNotification) -> Call? {
        if let session = notification.object as? MediaSession {
            return CallManager.sharedInstance.findCallByMediaSession(session)
        }
        return nil
    }
}