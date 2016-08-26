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

/// The PhoneNotificationCenter class is used to add & remove phone observer.
open class PhoneNotificationCenter {
    
    /// Returns the singleton PhoneNotificationCenter.
    open static let sharedInstance = PhoneNotificationCenter()
    
	fileprivate var observers = NSHashTable<AnyObject>.weakObjects()
	
    /// Add phone observer
    ///
    /// - parameter observer: PhoneObserver object to add.
    /// - returns: Void
    open func addObserver(_ observer: PhoneObserver) {
        observers.add(observer)
    }
    
    /// Remove phone observer
    ///
    /// - parameter observer: PhoneObserver object to remove.
    /// - returns: Void
    open func removeObserver(_ observer: PhoneObserver) {
        observers.remove(observer)
    }
    
    func notifyIncomingCall(_ call: Call) {
		fire { $0.callIncoming(call) }
    }
    
    func notifyRefreshAccessTokenFailed() {
		fire { $0.refreshAccessTokenFailed() }
    }
	
	private func fire(_ closure:(_ observer: PhoneObserver) -> Void) {
		for observer in observers.allObjects as! [PhoneObserver] {
			closure(observer)
		}
	}
}
