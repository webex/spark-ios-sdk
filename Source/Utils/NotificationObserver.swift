//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class NotificationObserver: NSObject {
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    final func startObserving() {
        let notificationhandlerMap = getNotificationHandlerMap()
        for (notification, selector) in notificationhandlerMap {
            addObserver(Selector(selector), name: notification)
        }
    }
    
    final func stopObserving() {
        notificationCenter.removeObserver(self)
    }
    
    func getNotificationHandlerMap() -> [String: String] {
        return [String: String]()
    }
    
    private func addObserver(selector: Selector, name: String) {
        notificationCenter.addObserver(self, selector: selector, name: name, object: nil)
    }
}