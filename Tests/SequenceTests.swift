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
import Quick
import Nimble
@testable import SparkSDK

class SequenceSpec: QuickSpec {
    
    override func spec() {
        
        describe("compare locus event") {
            
            it("result is less than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = [201,202,203,204]
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.lessThan))
            }
            
            it("result is less than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 90
                current.rangeEnd = 95
                
                incoming.entries = [201,202,203,204]
                incoming.rangeStart = 190
                incoming.rangeEnd = 195
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.lessThan))
            }
            
            it("result is less than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = [101,102,103,104,105,106]
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.lessThan))
            }
            
            it("result is less than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 80
                current.rangeEnd = 95
                
                incoming.entries = [101,102,103,104,105,106]
                incoming.rangeStart = 80
                incoming.rangeEnd = 95
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.lessThan))
            }
            
            it("result is less than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104,105]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = [102,103,104,105,106,107]
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.lessThan))
            }
            
            it("result is less than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [100,101,102,103]
                current.rangeStart = 75
                current.rangeEnd = 90
                
                incoming.entries = [100,101,102,103,104,105]
                incoming.rangeStart = 80
                incoming.rangeEnd = 90
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.lessThan))
            }
            
            it("result is greater than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104,105]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = [102,103,104,105]
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.greaterThan))
            }
            
            it("result is greater than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 80
                current.rangeEnd = 95
                
                incoming.entries = [101,102,103,104]
                incoming.rangeStart = 85
                incoming.rangeEnd = 95
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.greaterThan))
            }
            
            it("result is greater than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = []
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.greaterThan))
            }
            
            it("result is greater than") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103]
                current.rangeStart = 80
                current.rangeEnd = 95
                
                incoming.entries = []
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.greaterThan))
            }
            
            it("result is equal") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = []
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = []
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.equal))
            }
            
            it("result is equal") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = [101,102,103,104]
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.equal))
            }
            
            it("result is equal") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 50
                current.rangeEnd = 75
                
                incoming.entries = [101,102,103,104]
                incoming.rangeStart = 50
                incoming.rangeEnd = 75
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.equal))
            }
            
            it("result is desync") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,106,107]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = [101,102,103,104,105,107,108]
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.deSync))
            }
            
            it("result is desync") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,106,107]
                current.rangeStart = 80
                current.rangeEnd = 90
                
                incoming.entries = [101,102,103,104,105,107,108]
                incoming.rangeStart = 80
                incoming.rangeEnd = 90
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.deSync))
            }
            
            it("result is desync") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 0
                current.rangeEnd = 0
                
                incoming.entries = [101,102,103,105]
                incoming.rangeStart = 0
                incoming.rangeEnd = 0
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.deSync))
            }
            
            it("result is desync") {
                
                var current = Sequence()
                var incoming = Sequence()
                
                current.entries = [101,102,103,104]
                current.rangeStart = 80
                current.rangeEnd = 90
                
                incoming.entries = [101,102,103,105]
                incoming.rangeStart = 80
                incoming.rangeEnd = 90
                
                let result = CallInfoSequence.compare(current, incoming)
                expect(result).to(equal(CallInfoSequence.CompareResult.deSync))
            }
        }
    }
}
