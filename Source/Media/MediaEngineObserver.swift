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

class MediaEngineObserver: NotificationObserver {
    
    private var activeCall: Call? {
        return CallManager.sharedInstance.getActiveCall()
    }
    
    override func getNotificationHandlerMap() -> [String: String] {
        return [
            MediaEngineDidMuteVideoNotification:             "onMediaEngineDidMuteVideo:",
            MediaEngineDidUnMuteVideoNotification:           "onMediaEngineDidUnMuteVideo:",
            MediaEngineDidMuteAudioNotification:             "onMediaEngineDidMuteAudio:",
            MediaEngineDidUnMuteAudioNotification:           "onMediaEngineDidUnMuteAudio:",
            MediaEngineDidConnectNotification:               "onMediaEngineDidConnect:",
            MediaEngineDidDisconnectNotification:            "onMediaEngineDidDisconnect:",
            MediaEngineDidFailToConnectNotification:         "onMediaEngineDidFail:",
            MediaEngineDidSendFirstVideoDataNotification:    "onMediaEngineNotification:",
            MediaEngineDidSendFirstAudioDataNotification:    "onMediaEngineNotification:",
            MediaEngineDidReceiveFirstVideoDataNotification: "onMediaEngineNotification:",
            AVAudioSessionRouteChangeNotification:           "onMediaEngineAudioSessionRouteChangeNotification:"]
    }
    
    @objc private func onMediaEngineDidMuteVideo(notification: NSNotification) {
        if let call = activeCall {
            let sendingAudio = call.sendingAudio
            call.updateMedia(sendingAudio, false)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteVideo(notification: NSNotification) {
        if let call = activeCall {
            let sendingAudio = call.sendingAudio
            call.updateMedia(sendingAudio, true)
        }
        
    }
    
    @objc private func onMediaEngineDidMuteAudio(notification: NSNotification) {
        if let call = activeCall {
            let sendingVideo = call.sendingVideo
            call.updateMedia(false, sendingVideo)
        }
    }
    
    @objc private func onMediaEngineDidUnMuteAudio(notification: NSNotification) {
        if let call = activeCall {
            let sendingVideo = call.sendingVideo
            call.updateMedia(true, sendingVideo)
        }
    }
    
    @objc private func onMediaEngineDidConnect(notification: NSNotification) {
        Logger.info(notification.description)
    }
    
    @objc private func onMediaEngineDidDisconnect(notification: NSNotification) {
        Logger.info(notification.description)
    }
    
    @objc private func onMediaEngineDidFail(notification: NSNotification) {
        Logger.info(notification.description)
    }
    
    @objc private func onMediaEngineNotification(notification: NSNotification) {
        Logger.info(notification.description)
    }
    
    @objc private func onMediaEngineAudioSessionRouteChangeNotification(notification: NSNotification) {
        Logger.info(notification.description)
    }
}