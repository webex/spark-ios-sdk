//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class CallState {
    
    weak var call: Call!
    let callManager = CallManager.sharedInstance
    
    init(_ call: Call) {
        self.call = call
    }
    
    var info: CallInfo {
        return call.info!
    }
    
    var status: Call.Status {
        return .Disconnected
    }
    
    func update() {
    }
    
    final func postNotification(notification: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: call, userInfo: nil)
        print("postNotification: \(notification)")
    }
}