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