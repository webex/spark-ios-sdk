//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class CallInfoSequence {
    
    enum OverwriteResult {
        // the value passed in is newer than the current CallInfo
        case True
        // the value passed in is older than or equal to the current CallInfo
        case False
        // there are inconsistencies between the two versions - they both contain overlapping unique values
        case DeSync
    }
    
    enum CompareResult {
        case GreaterThan
        case LessThan
        case Equal
        case DeSync
    }
    
    // calculate "only in a's" list and "only in b's" list
    static func populateSets(a: Sequence, _ b: Sequence) -> ([UInt64], [UInt64]) {
        
        var aOnly = [UInt64]()
        var bOnly = [UInt64]()
        var aArray = a.getEntries()
        var bArray = b.getEntries()
        
        var atEndOfA = false
        var atEndOfB = false
        var indexOfA = 0
        var indexOfB = 0
        
        while (indexOfA < aArray.count && indexOfB < bArray.count) {
            var aVal = aArray[indexOfA]
            var bVal = bArray[indexOfB]
            
            indexOfA += 1
            indexOfB += 1
            
            while (aVal != bVal && !atEndOfA && !atEndOfB) {
                while (aVal > bVal) {
                    if !a.inRange(bVal) {
                        bOnly.append(bVal)
                    }
                    if indexOfB < bArray.count {
                        bVal = bArray[indexOfB]
                        indexOfB += 1
                    } else {
                        atEndOfB = true
                        break
                    }
                }
                
                while (bVal > aVal) {
                    if !b.inRange(aVal) {
                        aOnly.append(aVal)
                    }
                    if indexOfA < aArray.count {
                        aVal = aArray[indexOfA]
                        indexOfA += 1
                    } else {
                        atEndOfA = true
                        break
                    }
                }
            }
            
            if (atEndOfA && !atEndOfB) {
                if (!a.inRange(bVal)) {
                    bOnly.append(bVal)
                }
            }
            
            if ( !atEndOfA && atEndOfB) {
                if (!b.inRange(aVal)) {
                    aOnly.append(aVal)
                }
            }
        }
        
        while (indexOfA < aArray.count) {
            let aVal = aArray[indexOfA]
            indexOfA += 1
            if (!b.inRange(aVal)) {
                aOnly.append(aVal)
            }
        }
        
        while (indexOfB < bArray.count) {
            let bVal = bArray[indexOfB]
            indexOfB += 1
            if (!a.inRange(bVal)) {
                bOnly.append(bVal)
            }
        }
        
        return (aOnly, bOnly)
    }
    
    static func compare(a: Sequence, _ b: Sequence) -> CompareResult {
    
        var aOnly = [UInt64]()
        var bOnly = [UInt64]()
        
        // if all of a's values are less than b's, b is newer
        if a.getCompareLastValue() < b.getCompareFirstValue() {
            return CompareResult.LessThan
        }
        
        // if all of a's values are greater than b's, a is newer
        if a.getCompareFirstValue() > b.getCompareLastValue() {
            return CompareResult.GreaterThan
        }
        
        // calculate "only in a's" list and "only in b's" list
        (aOnly, bOnly) = populateSets(a, b)
        
        if aOnly.isEmpty && bOnly.isEmpty {
            // both sets are completely empty, use range to figure out order
            if a.getRangeEnd() > b.getRangeEnd() {
                return CompareResult.GreaterThan
            } else if a.getRangeEnd() < b.getRangeEnd() {
                return CompareResult.LessThan
            } else if a.getRangeStart() < b.getRangeStart() {
                return CompareResult.GreaterThan
            } else if a.getRangeStart() > b.getRangeStart() {
                return CompareResult.LessThan
            } else {
                return CompareResult.Equal
            }
        }
        
        // If b has nothing unique and a does, then a is newer
        if !aOnly.isEmpty && bOnly.isEmpty {
            return CompareResult.GreaterThan
        }
        
        // if I have nothing unique but b does, then b is newer
        if !bOnly.isEmpty && aOnly.isEmpty {
            return CompareResult.LessThan
        }
        
        // both have unique entries...
        // if a unique value in one list is within the min and max value in the others list then we are desync'd
        for i in aOnly {
            if i > b.getCompareFirstValue() && i < b.getCompareLastValue() {
                return CompareResult.DeSync
            }
        }
        for i in bOnly {
            if i > a.getCompareFirstValue() && i < a.getCompareLastValue() {
                return CompareResult.DeSync
            }
        }
        
        // aOnly and bOnly are 2 non-overlapping sets.  compare first item in both
        if aOnly[0] > bOnly[0] {
            return CompareResult.GreaterThan
        } else {
            return CompareResult.LessThan
        }
    }
    
    static func overwrite(oldValue oldValue: Sequence, newValue: Sequence) -> OverwriteResult {
        
        // special case the empty sequence.  If you are currently empty then say update no matter what
        if oldValue.isEmpty() || newValue.isEmpty() {
            return OverwriteResult.True
        } else {
            let compareResult = compare(oldValue, newValue)
            switch (compareResult) {
            case CompareResult.GreaterThan:
                return OverwriteResult.False
            case CompareResult.LessThan:
                return OverwriteResult.True
            case CompareResult.Equal:
                return OverwriteResult.False
            case CompareResult.DeSync:
                return OverwriteResult.DeSync
            }
        }
    }
}
