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
import ObjectMapper

struct SequenceModel {
    
    var entries: [UInt64] = []
    var rangeStart: UInt64 = 0
    var rangeEnd: UInt64 = 0
    
    var empty: Bool {
        return entries.isEmpty && rangeStart == 0 && rangeEnd == 0
    }
    
    var start: UInt64 {
        let v = self.rangeStart
        return v > 0 ? v : (self.entries.first ?? 0)
    }
    
    var end: UInt64 {
        let v = self.entries.last ?? 0
        return v > 0 ? v : self.rangeEnd
    }
    
    init() { // test purpose only
    }
    
    func inRange(_ value: UInt64) -> Bool {
        return value >= self.rangeStart && value <= self.rangeEnd
    }

}

extension SequenceModel: Mappable {
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        entries <- (map["entries"], UInt64Transform())
        rangeStart <- (map["rangeStart"], UInt64Transform())
        rangeEnd <- (map["rangeEnd"], UInt64Transform())
    }
}


