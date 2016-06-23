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

class UserDefaults {
    static var sharedInstance = UserDefaults()
    
    private let storage = NSUserDefaults.standardUserDefaults()
    
    private let DeviceUrl = "deviceUrlKey"
    private let IsVideoLicenseActivationDisabled = "isVideoLicenseActivationDisabledKey"
    private let IsVideoLicenseActivated = "isVideoLicenseActivatedKey"
    
    var deviceUrl: String? {
        get {
            return storage.stringForKey(DeviceUrl)
        }
        set {
            if newValue == nil {
                storage.removeObjectForKey(DeviceUrl)
            } else {
                storage.setObject(newValue, forKey: DeviceUrl)
            }
        }
    }
    
    var isVideoLicenseActivationDisabled: Bool {
        get {
            return storage.boolForKey(IsVideoLicenseActivationDisabled)
        }
        set {
            storage.setBool(newValue, forKey: IsVideoLicenseActivationDisabled)
        }
    }
    
    var isVideoLicenseActivated: Bool {
        get {
            return storage.boolForKey(IsVideoLicenseActivated)
        }
        set {
            storage.setBool(newValue, forKey: IsVideoLicenseActivated)
        }
    }
    
    func removeVideoLicenseSetting() {
        storage.removeObjectForKey(IsVideoLicenseActivationDisabled)
        storage.removeObjectForKey(IsVideoLicenseActivated)
    }
}