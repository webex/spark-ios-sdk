// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
