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