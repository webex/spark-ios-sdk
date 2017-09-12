//
//  DispatchQueue+asyncOnce.swift
//  SparkSDK
//
//  Created by panzh on 12/09/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    public func asyncOnce(token: String, block:@escaping (Void)->Void) {
        self.async {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            
            print("++++++Token :\(token)")
            if token.isEmpty || DispatchQueue._onceTracker.contains(token) {
                return
            }
        
            DispatchQueue._onceTracker.append(token)
            block()
        }
        
    }
    
    public func removeOnceToken(token: String) {
        self.async {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            if token.isEmpty {
                return
            }
            print("++++++RemoveToken :\(token)")
            DispatchQueue._onceTracker.removeObject(token)
        }
    }
}
