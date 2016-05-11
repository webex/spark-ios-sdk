//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

// TODO: rename class name?
class HttpParameters {
    private var storage:[String: AnyObject] = [:]
    
    // TODO: figure out why need to convert to String 
    init(_ parameters: [String: Any?] = [:]) {
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

    func value() -> [String: AnyObject] {
        return storage
    }
    
    func updateValue(value: AnyObject, forKey key: String) {
        storage.updateValue(value, forKey: key)
    }
}