//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

// TODO: need to check if setting is per user
class UserDefaults {
    static var sharedInstance: UserDefaults = UserDefaults(NSUserDefaultsAdapter())
    
    private let storage: Storagable
    
    init(_ storage: Storagable) {
        self.storage = storage
    }
    
    private let DeviceUrl = "deviceUrlKey"
    private let FacingMode = "facingModeKey"
    private let LoudSpeaker = "loudSpeakerKey"
    
    var deviceUrl: String? {
        get {
            return storage.stringForKey(DeviceUrl)
        }
        set {
            storage.setObject(newValue, forKey: DeviceUrl)
            storage.synchronize()
        }
    }
    
    func removeDeviceUrl() {
        storage.removeObjectForKey(DeviceUrl)
        storage.synchronize()
    }
    
    var facingMode: String? {
        get {
            return storage.stringForKey(FacingMode)
        }
        set {
            storage.setObject(newValue, forKey: FacingMode)
            storage.synchronize()
        }
    }
    
    var loudSpeaker: Bool? {
        get {
            return storage.objectForKey(LoudSpeaker) as? Bool
        }
        set {
            storage.setBool(newValue!, forKey: LoudSpeaker)
            storage.synchronize()
        }
    }
}