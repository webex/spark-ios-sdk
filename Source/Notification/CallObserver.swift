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

/// The DisconnectionType enum defines call disconnection type.
public enum DisconnectionType : String {
    case LocalLeft
    case LocalDeclined
    case LocalCancelled
    case RemoteLeft
    case RemoteDeclined
    case RemoteCancelled
    case OtherDeviceDeclined
    case OtherDeviceConnected
}

/// The MediaChangeType enum defines remote media change type.
public enum MediaChangeType {
    case RemoteVideoMuted
    case RemoteVideoUnmuted
    case RemoteAudioMuted
    case RemoteAudioUnmuted
}

/// The CallObserver protocol defines callback methods that observer object implement to respond to call notification.
public protocol CallObserver: AnyObject {
    
    /// Callback when remote participant(s) is ringing.
    ///
    /// - parameter call: Call object for the notification
    func callDidBeginRinging(call: Call)
    
    /// Callback when remote participant(s) answered and call gets connected.
    ///
    /// - parameter call: Call object for the notification
    /// - returns: Void
    func callDidConnect(call: Call)
    
    /// Callback when call gets disconnected (hangup, cancelled, get declined or other self device pickup the call).
    ///
    /// - parameter call: Call object for the notification
    /// - parameter disconnectionType: Call disconnection type, for example, RemoteLeft (remote participant left).
    /// - returns: Void
    func callDidDisconnect(call: Call, disconnectionType: DisconnectionType)
    
    /// Callback when remote participant(s) muted/unmuted video/audio.
    ///
    /// - parameter call: Call object for the notification
    /// - parameter mediaChangeType: Remote media change type, for example, RemoteVideoMuted (remote participant muted video).
    /// - returns: Void
    func remoteMediaDidChange(call: Call, mediaChangeType: MediaChangeType)
    
    /// Callback when self participant enable DTMF change.
    ///
    /// - parameter call: Call object for the notification
    /// - parameter sendingDTMFEnabled: The new value of sendingDTMFEnabled.
    /// - returns: Void
    func enableDTMFDidChange(call: Call, sendingDTMFEnabled: Bool)
}

/// The default empty callback methods for CallObserver protocol.
public extension CallObserver {
    
    func callDidBeginRinging(call: Call) {
    }
    
    func callDidConnect(call: Call) {
    }
    
    func callDidDisconnect(call: Call, disconnectionType: DisconnectionType) {
    }
    
    func remoteMediaDidChange(call: Call, mediaChangeType: MediaChangeType) {
    }
    
    func enableDTMFDidChange(call: Call, sendingDTMFEnabled: Bool) {
    }
}