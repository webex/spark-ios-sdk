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
import XCTest
import ObjectMapper
@testable import SparkSDK

class MediaInfoTests: XCTestCase {
    var testObject: MediaInfo!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let reachability = Reachability(JSON: ["https" : ["latencyInMilliseconds" : "123", "reachable" : "true"]])
        XCTAssertNotNil(reachability)
        testObject = MediaInfo(sdp: "Initial SDP", audioMuted: false, videoMuted: false, reachabilities: ["cluster1": reachability!])
        testObject.csis = [1,2,3,4,5]
    }

    func testMediaInfoConvertsToValidJSONObject() {
        let jsonTestObject = Mapper().toJSON(testObject)
        XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonTestObject))
    }

    func testMediaInfoConvertsToJSONStringAndBackAgain() {
        let jsonString = testObject.toJSONString(prettyPrint: true)
        XCTAssertNotNil(jsonString)
        let newObject = MediaInfo(JSONString: jsonString!)
        XCTAssertNotNil(newObject)
        XCTAssertNotNil(newObject!.csis)
        XCTAssertEqual(newObject!.csis!, testObject.csis!)
        let latency = newObject?.reachabilities?["cluster1"]?.https?.latencyInMilliseconds
        XCTAssertEqual(latency, 123)
        XCTAssertNotNil(newObject?.type)
    }

}
