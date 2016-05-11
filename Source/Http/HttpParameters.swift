//
//  HttpParameters.swift
//  Pods
//
//  Created by niliu2 on 3/12/16.
//
//

import Foundation

// TODO: rename class name?
public class HttpParameters {
    private var storage:[String: AnyObject] = [:]
    
    // TODO: figure out why need to convert to String 
    public init(_ parameters: [String: Any?] = [:]) {
        for (key, value) in parameters {
            if value == nil {
                continue
            }

            switch value {
            case let boolValue as Bool:
                storage.updateValue("\(boolValue)", forKey: key)
            case let intValue as Int:
                storage.updateValue("\(intValue)", forKey: key)
            case let stringValue as String:
                storage.updateValue(stringValue, forKey: key)
            case let otherValue as AnyObject:
                storage.updateValue(otherValue, forKey: key)
            default:
                break
            }
        }
    }

    public func value() -> [String: AnyObject] {
        return storage
    }
    
    public func updateValue(value: AnyObject, forKey key: String) {
        storage.updateValue(value, forKey: key)
    }
}