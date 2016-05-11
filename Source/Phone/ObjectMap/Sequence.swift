//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

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
        entries <- map["entries"]
        rangeStart <- map["rangeStart"]
        rangeEnd <- map["rangeEnd"]
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
}