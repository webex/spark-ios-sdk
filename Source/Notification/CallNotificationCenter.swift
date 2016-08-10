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

/// The CallNotificationCenter class is used to add & remove call observer.
public class CallNotificationCenter {
    
    /// Returns the singleton CallNotificationCenter.
    public static let sharedInstance = CallNotificationCenter()
    
    private var observers = WeakArray<CallObserver>()
    
    /// Add call observer
    ///
    /// - parameter observer: CallObserver object to add.
    /// - returns: Void
    public func addObserver(observer: CallObserver) {
        observers.append(observer)
    }
    
    /// Remove call observer
    ///
    /// - parameter observer: CallObserver object to remove.
    /// - returns: Void
    public func removeObserver(observer: CallObserver) {
        observers.remove(observer)
    }
    
    func notifyCallRinging(call: Call) {
        for observer in observers {
            observer.callDidBeginRinging(call)
        }
    }
    
    func notifyCallConnected(call: Call) {
        for observer in observers {
            observer.callDidConnect(call)
        }
    }
    
    func notifyCallDisconnected(call: Call, disconnectionType: DisconnectionType) {
        for observer in observers {
            observer.callDidDisconnect(call, disconnectionType: disconnectionType)
        }
    }
    
    func notifyRemoteMediaChanged(call: Call, mediaUpdatedType: RemoteMediaChangeType) {
        for observer in observers {
            observer.remoteMediaDidChange(call, remoteMediaChangeType: mediaUpdatedType)
        }
    }
    
    func notifyLocalMediaChanged(call: Call, mediaUpdatedType: LocalMediaChangeType) {
        for observer in observers {
            observer.localMediaDidChange(call, localMediaChangeType: mediaUpdatedType)
        }
    }
    
    func notifyFacingModeChanged(call: Call, facingMode: Call.FacingMode) {
        for observer in observers {
            observer.facingModeDidChange(call, facingMode: facingMode)
        }
    }
    
    func notifyLoudSpeakerChanged(call: Call, isLoudSpeakerSelected: Bool) {
        for observer in observers {
            observer.loudSpeakerDidChange(call, isLoudSpeakerSelected: isLoudSpeakerSelected)
        }
    }
    
    func notifyRemoteViewSizeChanged(call: Call, height: UInt32, width: UInt32) {
        for observer in observers {
            observer.remoteViewSizeDidChange(call, height: height, width: width)
        }
    }
    
    func notifyLocalViewSizeChanged(call: Call, height: UInt32, width: UInt32) {
        for observer in observers {
            observer.localViewSizeDidChange(call, height: height, width: width)
        }
    }
    
    func notifyEnableDTMFChanged(call: Call) {
        for observer in observers {
            observer.enableDTMFDidChange(call, sendingDTMFEnabled: call.sendingDTMFEnabled)
        }
    }
}
