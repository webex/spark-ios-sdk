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

/// The RemoteMediaChangeType enum defines remote media change type.
public enum RemoteMediaChangeType {
    /// Video is muted at remote side.
    case RemoteVideoMuted
    /// Video is unmuted at remote side.
    case RemoteVideoUnmuted
    /// Stop receiving video from media server, but remote side may still send video to media server.
    case RemoteVideoOutputMuted
    /// Receive video from media server.
    case RemoteVideoOutputUnmuted
    /// Audio is muted at remote side.
    case RemoteAudioMuted
    /// Audio is unmuted at remote side.
    case RemoteAudioUnmuted
    /// Stop receiving audio from media server, but remote side may still send audio to media server.
    case RemoteAudioOutputMuted
    /// Receive audio from media server.
    case RemoteAudioOutputUnmuted
}

/// The LocalMediaChangeType enum defines local media change type.
public enum LocalMediaChangeType {
    /// Video is muted at local side.
    case LocalVideoMuted
    /// Video is unmuted at local side.
    case LocalVideoUnmuted
    /// Audio is muted at local side.
    case LocalAudioMuted
    /// Audio is unmuted at local side.
    case LocalAudioUnmuted
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
    /// - parameter remoteMediaChangeType: Remote media change type, for example, RemoteVideoMuted (remote participant muted video).
    /// - returns: Void
    func remoteMediaDidChange(call: Call, remoteMediaChangeType: RemoteMediaChangeType)
    
    /// Callback when local host muted/unmuted video/audio.
    ///
    /// - parameter call: Call object for the notification
    /// - parameter localMediaChangeType: Local media change type, for example, LocalVideoMuted (local host muted video).
    /// - returns: Void
    func localMediaDidChange(call: Call, localMediaChangeType: LocalMediaChangeType)
    
    /// Callback when facing mode is changed.
    ///
    /// - parameter call: Call object for the notification
    /// - parameter facingMode: Facing mode (front/back camera)
    /// - returns: Void
    func facingModeDidChange(call: Call, facingMode: Call.FacingMode)
    
    /// Callback when loud speaker is changed.
    ///
    /// - parameter call: Call object for the notification
    /// - parameter isLoudSpeakerSelected: True if loud speaker is selected, false if not.
    /// - returns: Void
    func loudSpeakerDidChange(call: Call, isLoudSpeakerSelected: Bool)
    
    /// Callback when remote view size is changed.
    ///
    /// - parameter call: Call object for the notification
    /// - parameter height: Height for remote view.
    /// - parameter width: Width for remote view.
    /// - returns: Void
    func remoteViewSizeDidChange(call: Call, height: UInt32, width: UInt32)
    
    /// Callback when local view size is changed.
    ///
    /// - parameter call: Call object for the notification
    /// - parameter height: Height for local view.
    /// - parameter width: Width for local view.
    /// - returns: Void
    func localViewSizeDidChange(call: Call, height: UInt32, width: UInt32)

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
    
    func remoteMediaDidChange(call: Call, remoteMediaChangeType: RemoteMediaChangeType) {
    }

    func localMediaDidChange(call: Call, localMediaChangeType: LocalMediaChangeType) {
    }

    func facingModeDidChange(call: Call, facingMode: Call.FacingMode) {
    }

    func loudSpeakerDidChange(call: Call, isLoudSpeakerSelected: Bool) {
    }

    func remoteViewSizeDidChange(call: Call, height: UInt32, width: UInt32) {
    }

    func localViewSizeDidChange(call: Call, height: UInt32, width: UInt32) {
    }

    func enableDTMFDidChange(call: Call, sendingDTMFEnabled: Bool) {
    }
}