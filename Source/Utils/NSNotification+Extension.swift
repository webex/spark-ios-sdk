//
//  File.swift
//  Pods
//
//  Created by bxu3 on 4/8/16.
//
//

import Foundation
import ObjectMapper

extension NSNotification {
    var callInfo: CallInfo? {
        let notification = self.userInfo![Notifications.Locus.NotificationKey]
        if let callInfo = Mapper<CallEvent>().map(notification)?.callInfo {
            return callInfo
        }
        return nil
    }
    
    public var call: Call? {
        let notification = self.userInfo![Notifications.Phone.IncomingCallObjectKey]
        return notification as? Call
    }
}