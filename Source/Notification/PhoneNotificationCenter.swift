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

/// The PhoneNotificationCenter class is used to add & remove phone observer.
public class PhoneNotificationCenter {
    
    /// Returns the singleton PhoneNotificationCenter.
    public static let sharedInstance = PhoneNotificationCenter()
    
    private var observers = WeakArray<PhoneObserver>()
    
    /// Add phone observer
    ///
    /// - parameter observer: PhoneObserver object to add.
    /// - returns: Void
    public func addObserver(observer: PhoneObserver) {
        observers.append(observer)
    }
    
    /// Remove phone observer
    ///
    /// - parameter observer: PhoneObserver object to remove.
    /// - returns: Void
    public func removeObserver(observer: PhoneObserver) {
        observers.remove(observer)
    }
    
    func notifyIncomingCall(call: Call) {
        for observer in observers {
            observer.callIncoming(call)
        }
    }
    
    func notifyRefreshAccessTokenFailed() {
        for observer in observers {
            observer.refreshAccessTokenFailed()
        }
    }
}
