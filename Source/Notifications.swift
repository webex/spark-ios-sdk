//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Event notifications from SDK.
public struct Notifications {

    /// Event notifications for call.
    public struct Call {
        
        /// Remote participant(s) is ringing.
        public static let Ringing = "SparkSDK.call.ringing"
        
        /// Remote participant(s) answered and call gets connected.
        public static let Connected = "SparkSDK.call.connected"
        
        /// Call gets disconnected
        public static let Disconnected = "SparkSDK.call.disconnected"
        public static let AudioRouteChange = "SparkSDK.call.AudioRouteChange"
    }
    
    /// Event notifications for phone.
    public struct Phone {
        public static let Incoming = "SparkSDK.phone.incoming"
        public static let IncomingCallObjectKey = "IncomingCallObjectKey"
        
        public static let AuthSuccess                     = "SparkSDK.phone.auth.success"
        public static let AuthFail                        = "SparkSDK.phone.auth.fail"
        public static let WebSocketFail                   = "SparkSDK.phone.websocket.fail"
        public static let CameraMicrophoneAccessDenied    = "SparkSDK.phone.Camera.Microphone.AccessDenied"
    }
}
