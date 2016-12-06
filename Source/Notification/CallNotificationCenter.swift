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
    @available(*, deprecated, message: "Use Spark.callNotificationCenter instead")
    public static var sharedInstance: CallNotificationCenter {
        return SparkInstance.sharedInstance.callManager.callNotificationCenter
    }
    
    private var observers = NSHashTable<AnyObject>.weakObjects()
    
    /// Add call observer
    ///
    /// - parameter observer: CallObserver object to add.
    /// - returns: Void
    public func add(observer: CallObserver) {
        observers.add(observer)
    }
    
    /// Remove call observer
    ///
    /// - parameter observer: CallObserver object to remove.
    /// - returns: Void
    public func remove(observer: CallObserver) {
        observers.remove(observer)
    }
    
    func notifyIncomingCall(_ call: Call) {
        fire { $0.callIncoming(call) }
    }
    
    func notifyCallRinging(_ call: Call) {
        fire { $0.callDidBeginRinging(call) }
    }
    
    func notifyCallConnected(_ call: Call) {
        fire { $0.callDidConnect(call) }
    }
    
    func notifyCallDisconnected(_ call: Call, disconnectionType: DisconnectionType) {
        fire { $0.callDidDisconnect(call, disconnectionType: disconnectionType) }
    }
    
    func notifyRemoteMediaChanged(_ call: Call, mediaUpdatedType: RemoteMediaChangeType) {
        fire { $0.remoteMediaDidChange(call, remoteMediaChangeType: mediaUpdatedType) }
    }
    
    func notifyLocalMediaChanged(_ call: Call, mediaUpdatedType: LocalMediaChangeType) {
        fire { $0.localMediaDidChange(call, localMediaChangeType: mediaUpdatedType) }
    }
    
    func notifyFacingModeChanged(_ call: Call, facingMode: Call.FacingMode) {
        fire { $0.facingModeDidChange(call, facingMode: facingMode) }
    }
    
    func notifyLoudSpeakerChanged(_ call: Call, isLoudSpeakerSelected: Bool) {
        fire { $0.loudSpeakerDidChange(call, isLoudSpeakerSelected: isLoudSpeakerSelected) }
    }
    
    func notifyRemoteViewSizeChanged(_ call: Call, height: UInt32, width: UInt32) {
        fire { $0.remoteViewSizeDidChange(call, height: height, width: width) }
    }
    
    func notifyLocalViewSizeChanged(_ call: Call, height: UInt32, width: UInt32) {
        fire { $0.localViewSizeDidChange(call, height: height, width: width) }
    }
    
    func notifyEnableDTMFChanged(_ call: Call) {
        fire { $0.enableDTMFDidChange(call, sendingDTMFEnabled: call.sendingDTMFEnabled) }
    }
	
    private func fire(_ closure:(_ observer: CallObserver) -> Void) {
        for observer in observers.allObjects as! [CallObserver] {
            closure(observer)
        }
    }
}
