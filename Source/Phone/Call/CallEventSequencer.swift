//
//  CallEventSequencer.swift
//  SparkSDK
//
//  Created by zhiyuliu on 27/03/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

class CallEventSequencer {
    
    enum CompareResult {
        case greaterThan
        case lessThan
        case equal
        case deSync
    }
    
    static func sequence(old: CallModel?, new: CallModel, invalid: () -> Void) -> CallModel? {
        guard let old = old, let oldSeq = old.sequence, let newSeq = new.sequence else {
            return new
        }
        // special case the empty sequence.  If you are currently empty then say update no matter what
        if oldSeq.empty || newSeq.empty {
            return new
        }
        let compare = CallEventSequencer.compare(oldSeq, newSeq)
        switch compare {
        case .equal:
            return nil
        case .greaterThan:
            return nil
        case .lessThan:
            return new
        case .deSync:
            invalid()
            return nil
        }
    }
    
    private static func compare(_ a: SequenceModel, _ b: SequenceModel) -> CompareResult {
        
        var aOnly = [UInt64]()
        var bOnly = [UInt64]()
        
        // If all of a's values are less than b's, b is newer
        if a.end < b.start {
            return CompareResult.lessThan
        }
        
        // If all of a's values are greater than b's, a is newer
        if a.start > b.end {
            return CompareResult.greaterThan
        }
        
        (aOnly, bOnly) = self.populate(a, b)
        
        if aOnly.isEmpty && bOnly.isEmpty {
            // both sets are completely empty, use range to figure out order
            if a.rangeEnd > b.rangeEnd {
                return CompareResult.greaterThan
            } else if a.rangeEnd < b.rangeEnd {
                return CompareResult.lessThan
            } else if a.rangeStart < b.rangeStart {
                return CompareResult.greaterThan
            } else if a.rangeStart > b.rangeStart {
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
            if i > b.start && i < b.end {
                return CompareResult.deSync
            }
        }
        for i in bOnly {
            if i > a.start && i < a.end {
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
    
    // Calculate "only in a's" list and "only in b's" list
    // Need Refactoring
    private static func populate(_ a: SequenceModel, _ b: SequenceModel) -> ([UInt64], [UInt64]) {
        
        var aOnly = [UInt64]()
        var bOnly = [UInt64]()
        var aArray = a.entries
        var bArray = b.entries
        
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
}
