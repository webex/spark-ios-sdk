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

struct Sequence: Mappable {
    
    var entries: [UInt64] = []
    var rangeStart: UInt64 = 0
    var rangeEnd: UInt64 = 0
    
    init() { // test purpose only
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        entries <- (map["entries"], UInt64Transform())
        rangeStart <- (map["rangeStart"], UInt64Transform())
        rangeEnd <- (map["rangeEnd"], UInt64Transform())
    }
    
    func getEntries() -> [UInt64] {
        return entries
    }
    
    func getRangeStart() -> UInt64 {
        return rangeStart
    }
    
    func getRangeEnd() -> UInt64 {
        return rangeEnd
    }
    
    func isEmpty() -> Bool {
        return entries.isEmpty && rangeStart == 0 && rangeEnd == 0
    }
    
    func getEntriesFirstValue() -> UInt64 {
        if entries.isEmpty {
            return 0
        } else {
            return entries.first!
        }
    }
    
    func getEntriesLastValue() -> UInt64 {
        if entries.isEmpty {
            return 0
        } else {
            return entries.last!
        }
    }
    
    func getCompareFirstValue() -> UInt64 {
        var retVal = getRangeStart()
        
        if (retVal == 0) {
            retVal = getEntriesFirstValue()
        }
        
        return retVal
    }
    
    func getCompareLastValue() -> UInt64 {
        var retVal = getEntriesLastValue()
        
        if (retVal == 0) {
            retVal = getRangeEnd()
        }
        
        return retVal
    }
    
    func inRange(value: UInt64) -> Bool {
        return value >= getRangeStart() && value <= getRangeEnd() 
    }
    
    class UInt64Transform: TransformType {
        typealias Object = UInt64
        typealias JSON = String
        
        func transformFromJSON(value: AnyObject?) -> Object?{
            if let number = value as? NSNumber {
                let uint64Value = number.unsignedLongLongValue
                return uint64Value
            }
            
            return nil
        }
        
        func transformToJSON(value: Object?) -> JSON? {
            return nil
        }
    }
}