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
        
        /// Call gets disconnected (hangup, cancelled, get declined or other self device pickup the call).
        public static let Disconnected = "SparkSDK.call.disconnected"
    }
    
    /// Event notifications for phone.
    public struct Phone {
        
        /// Gets an incoming call.
        public static let Incoming = "SparkSDK.phone.incoming"
        
        /// Dictionary key used to get call object in an incoming call notification.
        public static let IncomingCallObjectKey = "IncomingCallObjectKey"
        
        /// Refreshes access token failed, and App must login again if recieves this notification.
        public static let RefreshAccessTokenFailed = "SparkSDK.phone.refreshAccessTokenFailed"
    }
}
