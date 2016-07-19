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
                expect(result).to(equal(CallInfoSequence.CompareResult.LessThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.LessThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.LessThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.LessThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.LessThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.LessThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.LessThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.GreaterThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.GreaterThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.GreaterThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.GreaterThan))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.Equal))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.Equal))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.Equal))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.DeSync))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.DeSync))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.DeSync))
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
                expect(result).to(equal(CallInfoSequence.CompareResult.DeSync))
            }
        }
    }
}
