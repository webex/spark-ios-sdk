//
//  Storagable.swift
//  Pods
//
//  Created by bxu3 on 4/12/16.
//
//
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

