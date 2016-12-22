//
//  MediaInfoTests.swift
//  SparkSDK
//
//  Created by dev1 on 12/21/16.
//  Copyright © 2016 Cisco. All rights reserved.
//

import Foundation
import XCTest
import ObjectMapper
@testable import SparkSDK

class MediaInfoTests: XCTestCase {
    var testObject: MediaInfo!
    
    override func setUp() {
        super.setUp()
        let map = Map(mappingType: .fromJSON, JSON: ["key":"value", "key2":2])
        testObject = MediaInfo(sdp: "Initial SDP", audioMuted: false, videoMuted: false, reachabilities: ["string": Reachability(map: map)!])
        testObject.csis = [1,2,3,4,5]
        testObject.type = "SDP"
    }

    func testMediaInfoConvertsToValidJSONObject() {
        XCTAssertFalse(JSONSerialization.isValidJSONObject(testObject))
        let jsonTestObject = Mapper().toJSON(testObject)
        XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonTestObject))
    }

    func testMediaInfoConvertsToJSONStringWithPrettyPrinting() {
        let stringifiedJSONObject = testObject.toJSONString(prettyPrint: true)
        XCTAssertNotNil(stringifiedJSONObject)
    }

    func testMediaInfoConvertsToJSONStringWithoutPrettyPrinting() {
        let stringifiedJSONObject = testObject.toJSONString(prettyPrint: false)
        XCTAssertNotNil(stringifiedJSONObject)
    }
}
