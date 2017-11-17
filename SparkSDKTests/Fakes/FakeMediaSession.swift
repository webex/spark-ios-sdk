//
//  FakeMediaSession.swift
//  SparkSDKTests
//
//  Created by panzh on 14/11/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
@testable import SparkSDK

class FakeMediaSession: MediaSession  {
    static func stubMediaChangeNotification(eventType:Call.MediaChangedEvent,call:Call) {
        DispatchQueue.main.async {
            switch eventType {
            case .sendingVideo(let isSending):
                if isSending {
                    NotificationCenter.default.post(name: NSNotification.Name.MediaEngineDidUnMuteVideo, object: call.mediaSession.getMediaSession())
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name.MediaEngineDidMuteVideo, object: call.mediaSession.getMediaSession())
                }
            default:
                break
            }
        }
        
    }
}
