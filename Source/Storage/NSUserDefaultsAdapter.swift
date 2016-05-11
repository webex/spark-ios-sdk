//
//  DefautStorage.swift
//  Pods
//
//  Created by bxu3 on 4/12/16.
//
//

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