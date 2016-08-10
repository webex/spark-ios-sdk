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

extension WeakArray {
    var count: Int {
        var count = 0
        self.forEach{_ in count += 1}
        return count
    }
}

class WeakArraySpec: QuickSpec {
    class Test {}

    override func spec() {
        describe("Weak Array") {
            it("Append & remove item") {
                let arr = WeakArray<Test>()
                let t: Test? = Test()
                arr.append(t)
                expect(arr.count).to(equal(1))
                arr.remove(t)
                expect(arr.count).to(equal(0))
            }
            
            it("Append duplicated items") {
                let arr = WeakArray<Test>()
                let t: Test? = Test()
                arr.append(t)
                arr.append(t)
                expect(arr.count).to(equal(1))
            }
        }
    }
}