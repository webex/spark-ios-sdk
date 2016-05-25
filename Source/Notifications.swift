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
