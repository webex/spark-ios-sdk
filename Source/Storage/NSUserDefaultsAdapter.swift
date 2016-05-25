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

class NSUserDefaultsAdapter: Storagable {
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func objectForKey(defaultName: String) -> AnyObject? {
        return userDefaults.objectForKey(defaultName)
    }
    
    func setObject(value: AnyObject?, forKey defaultName: String) {
        userDefaults.setObject(value, forKey: defaultName)
    }
    
    func removeObjectForKey(defaultName: String) {
        userDefaults.removeObjectForKey(defaultName)
    }
    
    func integerForKey(defaultName: String) -> Int {
        return userDefaults.integerForKey(defaultName)
    }
    
    func floatForKey(defaultName: String) -> Float {
        return userDefaults.floatForKey(defaultName)
    }
    
    func doubleForKey(defaultName: String) -> Double {
        return userDefaults.doubleForKey(defaultName)
    }
    
    func boolForKey(defaultName: String) -> Bool {
        return userDefaults.boolForKey(defaultName)
    }
    
    func stringForKey(defaultName: String) -> String? {
        return userDefaults.stringForKey(defaultName)
    }
    
    func arrayForKey(defaultName: String) -> [AnyObject]? {
        return userDefaults.arrayForKey(defaultName)
    }
    
    func dictionaryForKey(defaultName: String) -> [String: AnyObject]? {
        return userDefaults.dictionaryForKey(defaultName)
    }
    
    func dataForKey(defaultName: String) -> NSData? {
        return userDefaults.dataForKey(defaultName)
    }
    
    func stringArrayForKey(defaultName: String) -> [String]? {
        return userDefaults.stringArrayForKey(defaultName)
    }
    
    func setInteger(value: Int, forKey defaultName: String) {
        userDefaults.setInteger(value, forKey: defaultName)
    }
    
    func setFloat(value: Float, forKey defaultName: String) {
        userDefaults.setFloat(value, forKey: defaultName)
    }
    
    func setDouble(value: Double, forKey defaultName: String) {
        userDefaults.setDouble(value, forKey: defaultName)
    }
    
    func setBool(value: Bool, forKey defaultName: String) {
        userDefaults.setBool(value, forKey: defaultName)
    }
    
    func registerDefaults(registrationDictionary: [String: AnyObject]) {
        userDefaults.registerDefaults(registrationDictionary)
    }
    
    func synchronize() -> Bool {
        return userDefaults.synchronize()
    }
}