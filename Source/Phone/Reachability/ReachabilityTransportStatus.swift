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
import ObjectMapper

struct ReachabilityTransportStatus: Mappable {
    var latencyInMilliseconds: Int?
    var reachable: Bool?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        latencyInMilliseconds <- (map["latencyInMilliseconds"], StringAndIntTransform())
        reachable <- (map["reachable"], StringAndBoolTransform())
    }
    
    class StringAndIntTransform: TransformType {
        typealias Object = Int
        typealias JSON = String
        
        func transformFromJSON(value: AnyObject?) -> Object? {
            if let inputString = value as? String {
                return Int(inputString)
            } else if let inputInt = value as? Int {
                return inputInt
            }
            return nil
        }
        
        func transformToJSON(value: Object?) -> JSON? {
            guard let input = value else {
                return nil
            }
            return String(input)
        }
    }
    
    class StringAndBoolTransform: TransformType {
        typealias Object = Bool
        typealias JSON = String
        
        func transformFromJSON(value: AnyObject?) -> Object? {
            if let inputString = value as? String {
                switch inputString.lowercaseString {
                case "true": return true
                case "false": return false
                default: return nil
                }
            } else if let inputBool = value as? Bool {
                return inputBool
            }
            return nil
        }
        
        func transformToJSON(value: Object?) -> JSON? {
            guard let input = value else {
                return nil
            }
            return input ? "true" : "false"
        }
    }
}
