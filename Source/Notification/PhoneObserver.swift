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

/// The PhoneObserver protocol defines callback methods that observer object implement to respond to phone notification.
public protocol PhoneObserver: AnyObject {
    
    /// Callback when call is incoming.
    ///
    /// - parameter call: The incoming Call object
    /// - returns: Void
    func callIncoming(call: Call)
    
    /// Callback when refreshes access token failed. App must login again if recieves this notification.
    ///
    /// - returns: Void
    func refreshAccessTokenFailed()
}

/// The default empty callback methods for PhoneObserver protocol.
public extension PhoneObserver {
    
    func callIncoming(call: Call) {
    }
    
    func refreshAccessTokenFailed() {
    }
}