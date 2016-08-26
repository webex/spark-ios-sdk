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

class CallInfoSequence {
    
    enum OverwriteResult {
        // the value passed in is newer than the current CallInfo
        case `true`
        // the value passed in is older than or equal to the current CallInfo
        case `false`
        // there are inconsistencies between the two versions - they both contain overlapping unique values
        case deSync
    }
    
    enum CompareResult {
        case greaterThan
        case lessThan
        case equal
        case deSync
    }
    
    // calculate "only in a's" list and "only in b's" list
    static func populateSets(_ a: Sequence, _ b: Sequence) -> ([UInt64], [UInt64]) {
        
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
    
    static func compare(_ a: Sequence, _ b: Sequence) -> CompareResult {
    
        var aOnly = [UInt64]()
        var bOnly = [UInt64]()
        
        // if all of a's values are less than b's, b is newer
        if a.getCompareLastValue() < b.getCompareFirstValue() {
            return CompareResult.lessThan
        }
        
        // if all of a's values are greater than b's, a is newer
        if a.getCompareFirstValue() > b.getCompareLastValue() {
            return CompareResult.greaterThan
        }
        
        // calculate "only in a's" list and "only in b's" list
        (aOnly, bOnly) = populateSets(a, b)
        
        if aOnly.isEmpty && bOnly.isEmpty {
            // both sets are completely empty, use range to figure out order
            if a.getRangeEnd() > b.getRangeEnd() {
                return CompareResult.greaterThan
            } else if a.getRangeEnd() < b.getRangeEnd() {
                return CompareResult.lessThan
            } else if a.getRangeStart() < b.getRangeStart() {
                return CompareResult.greaterThan
            } else if a.getRangeStart() > b.getRangeStart() {
                return CompareResult.lessThan
            } else {
                return CompareResult.equal
            }
        }
        
        // If b has nothing unique and a does, then a is newer
        if !aOnly.isEmpty && bOnly.isEmpty {
            return CompareResult.greaterThan
        }
        
        // if I have nothing unique but b does, then b is newer
        if !bOnly.isEmpty && aOnly.isEmpty {
            return CompareResult.lessThan
        }
        
        // both have unique entries...
        // if a unique value in one list is within the min and max value in the others list then we are desync'd
        for i in aOnly {
            if i > b.getCompareFirstValue() && i < b.getCompareLastValue() {
                return CompareResult.deSync
            }
        }
        for i in bOnly {
            if i > a.getCompareFirstValue() && i < a.getCompareLastValue() {
                return CompareResult.deSync
            }
        }
        
        // aOnly and bOnly are 2 non-overlapping sets.  compare first item in both
        if aOnly[0] > bOnly[0] {
            return CompareResult.greaterThan
        } else {
            return CompareResult.lessThan
        }
    }
    
    static func overwrite(oldValue: Sequence, newValue: Sequence) -> OverwriteResult {
        
        // special case the empty sequence.  If you are currently empty then say update no matter what
        if oldValue.isEmpty() || newValue.isEmpty() {
            return OverwriteResult.true
        } else {
            let compareResult = compare(oldValue, newValue)
            switch (compareResult) {
            case CompareResult.greaterThan:
                return OverwriteResult.false
            case CompareResult.lessThan:
                return OverwriteResult.true
            case CompareResult.equal:
                return OverwriteResult.false
            case CompareResult.deSync:
                return OverwriteResult.deSync
            }
        }
    }
}
