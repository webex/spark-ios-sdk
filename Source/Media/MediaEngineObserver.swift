//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

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
            MediaEngineDidDisconnectNotification:            "onMediaEngineDidDisConnect:",
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
        print("onMediaEngineDidConnect")
        print(notification)
    }
    
    @objc private func onMediaEngineDidDisConnect(notification: NSNotification) {
        print("onMediaEngineDidDisConnect")
        print(notification)
    }
    
    @objc private func onMediaEngineDidFail(notification: NSNotification) {
        print("onMediaEngineDidFail")
        print(notification)
    }
    
    @objc private func onMediaEngineNotification(notification: NSNotification) {
        print("onMediaEngineNotification")
        print(notification)
    }
    
    @objc private func onMediaEngineAudioSessionRouteChangeNotification(notification: NSNotification) {
        print("onMediaEngineAudioSessionRouteChangeNotification")
    }
}