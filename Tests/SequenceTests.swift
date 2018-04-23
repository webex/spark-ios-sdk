// Copyright 2016-2018 Cisco Systems Inc
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
import XCTest
@testable import SparkSDK

class SequenceTests: XCTestCase {
    
//    func testHundredsToTwoHundredsIsLess() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104], incomingEntries: [201, 202, 203, 204])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.lessThan)
//    }
//    
//    func testHundredsToTwoHundredsWithHighRangesIsLess() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104], incomingEntries: [201, 202, 203, 204], currentStart: 90, currentEnd: 95, incomingStart: 190, incomingEnd: 195)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.lessThan)
//    }
//    
//    func testHundredsToHundredsWithSixIncomingIsLess() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104], incomingEntries: [101, 102, 103, 104, 105, 106])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.lessThan)
//    }
//    
//    func testHundredsToHundredsWithSixIncomingAndHighRangesIsLess() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104], incomingEntries: [101, 102, 103, 104, 105, 106], currentStart: 80, currentEnd: 95, incomingStart: 80, incomingEnd: 95)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.lessThan)
//    }
//    
//    func testHundredsToHundredsWithFiveCurrentAndSixLaterIncomingIsLess() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104, 105], incomingEntries: [102, 103, 104, 105, 106, 107])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.lessThan)
//    }
//    
//    func testHundredsToHundredsWithFiveEarlierCurrentAndSixEarlierIncomingAndHighRangesIsLess() {
//        let result = compareSequences(currentEntries: [100, 101, 102, 103], incomingEntries: [100, 101, 102, 103, 104, 105], currentStart: 75, currentEnd: 90, incomingStart: 80, incomingEnd: 90)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.lessThan)
//    }
//    
//    func testHundredsToHundredsWithFiveCurrentAndLaterIncomingIsGreater() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104, 105], incomingEntries: [102, 103, 104, 105])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.greaterThan)
//    }
//    
//    func testHundredsToHundredsWithHighRangesIsGreater() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104], incomingEntries: [101, 102, 103, 104], currentStart: 80, currentEnd: 95, incomingStart: 85, incomingEnd: 95)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.greaterThan)
//    }
//    
//    func testHundredsToNoIncomingWithThreeCurrentIsGreater() {
//        let result = compareSequences(currentEntries: [101, 102, 103], incomingEntries: [])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.greaterThan)
//    }
//    
//    func testHundredsToNoIncomingWithHighCurrentRangeAndThreeCurrentIsGreater() {
//        let result = compareSequences(currentEntries: [101, 102, 103], incomingEntries: [], currentStart: 80, currentEnd: 95)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.greaterThan)
//    }
//    
//    func testEmptyAllIsEqual() {
//        let result = compareSequences(currentEntries: [], incomingEntries: [])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.equal)
//    }
//    
//    func testHundredsToHundredsIsEqual() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104], incomingEntries: [101, 102, 103, 104])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.equal)
//    }
//    
//    func testHundredsToTwoHundredsWithSameHighRangesIsEqual() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 104], incomingEntries: [101, 102, 103, 104], currentStart: 50, currentEnd: 75, incomingStart: 50, incomingEnd: 75)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.equal)
//    }
//    
//    func testHundredsToHundredsWithFiveGapCurrentAndSevenGapIncomingIsDesync() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 106, 107], incomingEntries: [101,102,103,104,105,107,108])
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.deSync)
//    }
//    
//    func testHundredsToHundredsWithHighRangesAndFiveGapCurrentAndSevenGapIncomingIsDesync() {
//        let result = compareSequences(currentEntries: [101, 102, 103, 106, 107], incomingEntries: [101,102,103,104,105,107,108], currentStart: 80, currentEnd: 90, incomingStart: 80, incomingEnd: 90)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.deSync)
//    }
//    
//    func testHundredsToHundredsWithHighRangesAndGapIncomingIsDesync() {
//        let result = compareSequences(currentEntries: [101,102,103,104], incomingEntries: [101,102,103,105], currentStart: 80, currentEnd: 90, incomingStart: 80, incomingEnd: 90)
//        XCTAssertEqual(result, CallInfoSequence.CompareResult.deSync)
//    }
//    
//    private func compareSequences(currentEntries: [UInt64], incomingEntries: [UInt64], currentStart: UInt64 = 0, currentEnd: UInt64 = 0, incomingStart: UInt64 = 0, incomingEnd: UInt64 = 0) -> CallInfoSequence.CompareResult {
//        var current = Sequence()
//        var incoming = Sequence()
//        
//        current.entries = currentEntries
//        current.rangeStart = currentStart
//        current.rangeEnd = currentEnd
//        
//        incoming.entries = incomingEntries
//        incoming.rangeStart = incomingStart
//        incoming.rangeEnd = incomingEnd
//        
//        return CallInfoSequence.compare(current, incoming)
//    }
//    
}
