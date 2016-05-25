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

public protocol Storagable {
    func objectForKey(defaultName: String) -> AnyObject?
    func setObject(value: AnyObject?, forKey defaultName: String)
    func removeObjectForKey(defaultName: String)
    
    func integerForKey(defaultName: String) -> Int
    func floatForKey(defaultName: String) -> Float
    func doubleForKey(defaultName: String) -> Double
    func boolForKey(defaultName: String) -> Bool
    
    func stringForKey(defaultName: String) -> String?
    func arrayForKey(defaultName: String) -> [AnyObject]?
    func dictionaryForKey(defaultName: String) -> [String: AnyObject]?
    func dataForKey(defaultName: String) -> NSData?
    func stringArrayForKey(defaultName: String) -> [String]?
    
    func setInteger(value: Int, forKey defaultName: String)
    func setFloat(value: Float, forKey defaultName: String)
    func setDouble(value: Double, forKey defaultName: String)
    func setBool(value: Bool, forKey defaultName: String)
    
    func registerDefaults(registrationDictionary: [String: AnyObject])
    
    func synchronize() -> Bool
}

