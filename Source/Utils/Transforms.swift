//
//  Transforms.swift
//  SparkSDK
//
//  Created by Kyle on 2018/4/16.
//  Copyright © 2018 Cisco. All rights reserved.
//

import Foundation
import ObjectMapper

class UInt64Transform: TransformType {
    
    func transformFromJSON(_ value: Any?) -> UInt64?{
        return (value as? NSNumber)?.uint64Value
    }
    
    func transformToJSON(_ value: UInt64?) -> String? {
        if let value = value {
            return String(value)
        }
        return nil
    }
}

class EmailTransform: TransformType {
    
    func transformFromJSON(_ value: Any?) -> EmailAddress? {
        if let value = value as? String {
            return EmailAddress.fromString(value)
        } else {
            return nil
        }
    }
    
    func transformToJSON(_ value: EmailAddress?) -> String? {
        return value?.toString()
    }
}

class EmailsTransform: TransformType {
    
    func transformFromJSON(_ value: Any?) -> [EmailAddress]? {
        guard let value = (value as? [String]) else {
            return nil
        }
        var emails: [EmailAddress] = []
        for emailString in value {
            if let emailAddress = EmailAddress.fromString(emailString) {
                emails.append(emailAddress)
            } else {
                SDKLogger.shared.warn("\(emailString) is not a properly formatted email address")
            }
        }
        return emails
    }
    
    func transformToJSON(_ value: [EmailAddress]?) ->  [String]? {
        guard let value = value else {
            return nil
        }
        var emails: [String] = []
        for email in value {
            emails.append(email.toString())
        }
        return emails
    }
}

class StringAndIntTransform: TransformType {
    
    func transformFromJSON(_ value: Any?) -> Int? {
        if let inputString = value as? String {
            return Int(inputString)
        } else if let inputInt = value as? Int {
            return inputInt
        }
        return nil
    }
    
    func transformToJSON(_ value: Int?) -> String? {
        guard let input = value else {
            return nil
        }
        return String(input)
    }
}

class StringAndBoolTransform: TransformType {
    typealias Object = Bool
    typealias JSON = String
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if let inputString = value as? String {
            switch inputString.lowercased() {
            case "true": return true
            case "false": return false
            default: return nil
            }
        } else if let inputBool = value as? Bool {
            return inputBool
        }
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        guard let input = value else {
            return nil
        }
        return input ? "true" : "false"
    }
}
