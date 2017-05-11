// Copyright 2016-2017 Cisco Systems Inc
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

class PhoneTests: XCTestCase {
    
    private var fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private var phone: Phone!
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        phone = fixture.spark.phone
        XCTAssertNotNil(phone)
        XCTAssertTrue(registerPhone())
    }
    
    override func tearDown() {
        XCTAssertTrue(deregisterPhone())
    }
    
    func testWhenRegisterAndDeregisterPhoneThenBothSucceed() {
        // Tests that basic setup and teardown work without issue.
    }
    
    func testWhenRegisterPhoneTwiceThenBothSucceed() {
        XCTAssertTrue(registerPhone())
    }
    
    func testWhenDeregisterPhoneTwiceThenBothSuceed() {
        XCTAssertTrue(deregisterPhone())
    }
    
    func testWhenDialThenReturnsSuccessAndHangsUp() {
        if let user = fixture.createUser() {
            let mediaOption = MediaOption.audioVideo(local: MediaRenderView(), remote: MediaRenderView())
            phone.disableVideoCodecActivation()
            let call = dialCall(address: user.email.toString(), mediaOption: mediaOption)
            XCTAssertNotNil(call)
            XCTAssertTrue(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testWhenDialWithAudioOnlyThenReturnsSuccessAndHangsUp() {
        if let user = fixture.createUser() {
            let call = dialCall(address: user.email.toString(), mediaOption: MediaOption.audioOnly())
            XCTAssertNotNil(call)
            XCTAssertTrue(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testWhenDialWithSipAddressThenReturnsSuccessAndHangsUp() {
        let mediaOption = MediaOption.audioVideo(local: MediaRenderView(), remote: MediaRenderView())
        phone.disableVideoCodecActivation()
        let call = dialCall(address: "sip:9995839764@sip.tropo.com", mediaOption: mediaOption)
        XCTAssertNotNil(call)
        XCTAssertTrue(hangupCall(call: call!))
    }
    
    func testWhenDialWithAudioOnlyAndSipAddressThenReturnsSuccessAndHangsUp() {
        let call = dialCall(address: "sip:9995839764@sip.tropo.com", mediaOption: MediaOption.audioOnly())
        XCTAssertNotNil(call)
        XCTAssertTrue(hangupCall(call: call!))
    }
    
    private func registerPhone() -> Bool {
        var success = false
        
        let expect = expectation(description: "Phone registration")
        phone.register() { error in
            success = (error == nil)
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone registration timed out")
        }
        return success
    }
    
    private func deregisterPhone() -> Bool {
        guard let phone = phone else {
            return false
        }
        
        var success = false
        
        let expect = expectation(description: "Phone deregistration")
        phone.deregister() { error in
            success = (error == nil)
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone deregistration timed out")
        }
        
        return success
    }
    
    private func dialCall(address: String, mediaOption: MediaOption) -> Call? {
        let expect = expectation(description: "Call dial")
        var call:Call? = nil
        phone.dial(address, option: mediaOption) { result in
            call = result.data
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone dial timed out")
        }
        return call
    }
    
    private func hangupCall(call: Call) -> Bool {
        var success = false
        
        let expect = expectation(description: "Call hangup")
        call.hangup() { error in
            success = (error == nil)
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone hangup timed out")
        }
        return success
    }
}
