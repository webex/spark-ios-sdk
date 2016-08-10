// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// The DisconnectionType enum defines call disconnection type.
public enum DisconnectionType : String {
    /// Disconnect due to local left
    case LocalLeft
    /// Disconnect due to local declined
    case LocalDeclined
    /// Disconnect due to local cancelled
    case LocalCancelled
    /// Disconnect due to remote left
    case RemoteLeft
    /// Disconnect due to remote declined
    case RemoteDeclined
    /// Disconnect due to remote cancelled
    case RemoteCancelled
    /// Disconnect due to other device declined
    case OtherDeviceDeclined
    /// Disconnect due to other device connected
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
    
    /// Empty default implementation
    func callDidBeginRinging(call: Call) {
    }
    
    /// Empty default implementation
    func callDidConnect(call: Call) {
    }
    
    /// Empty default implementation
    func callDidDisconnect(call: Call, disconnectionType: DisconnectionType) {
    }
    
    /// Empty default implementation
    func remoteMediaDidChange(call: Call, remoteMediaChangeType: RemoteMediaChangeType) {
    }

    /// Empty default implementation
    func localMediaDidChange(call: Call, localMediaChangeType: LocalMediaChangeType) {
    }

    /// Empty default implementation
    func facingModeDidChange(call: Call, facingMode: Call.FacingMode) {
    }

    /// Empty default implementation
    func loudSpeakerDidChange(call: Call, isLoudSpeakerSelected: Bool) {
    }

    /// Empty default implementation
    func remoteViewSizeDidChange(call: Call, height: UInt32, width: UInt32) {
    }

    /// Empty default implementation
    func localViewSizeDidChange(call: Call, height: UInt32, width: UInt32) {
    }

    /// Empty default implementation
    func enableDTMFDidChange(call: Call, sendingDTMFEnabled: Bool) {
    }
}