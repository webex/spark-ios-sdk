//
//  Notifications.swift
//  Pods
//
//  Created by bxu3 on 4/11/16.
//
//

import Foundation

public struct Notifications {

    public struct Call {
        public static let Ringing                   = "SparkSDK.call.ringing"
        public static let Connected                 = "SparkSDK.call.connected"
        public static let Disconnected              = "SparkSDK.call.disconnected"
        public static let AudioRouteChange          = "SparkSDK.call.AudioRouteChange"
    }
    
    public struct Phone {
        public static let Incoming                  = "SparkSDK.phone.incoming"
        public static let IncomingCallObjectKey     = "IncomingCallObjectKey"
        
        public static let AuthSuccess                     = "SparkSDK.phone.auth.success"
        public static let AuthFail                        = "SparkSDK.phone.auth.fail"
        public static let WebSocketFail                   = "SparkSDK.phone.websocket.fail"
        public static let CameraMicrophoneAccessDenied    = "SparkSDK.phone.Camera.Microphone.AccessDenied"
    }
}
