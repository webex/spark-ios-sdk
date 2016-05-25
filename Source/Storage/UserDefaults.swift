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