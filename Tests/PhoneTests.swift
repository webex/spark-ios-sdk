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

class PhoneSpec: QuickSpec {
    
    private var fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private var phone: Phone!

    private func registerPhone() {
        var registerSuccess: Bool = false
        self.phone.register() {
            registerSuccess = $0
        }
        expect(registerSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
    }
    
    private func deregisterPhone() {
        var deregisterSuccess: Bool = false
        self.phone.deregister() {
            deregisterSuccess = $0
        }
        expect(deregisterSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
    }
    
    private func hangupCall(call: Call) {
        var hangupSuccess: Bool = false
        call.hangup {
            hangupSuccess = $0
        }
        expect(hangupSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
    }
    
    override func spec() {
        beforeSuite {
            self.continueAfterFailure = false
            XCTAssertNotNil(self.fixture)
            self.phone = self.fixture.spark.phone
        }
        
        describe("phone register") {
        
            beforeEach {
                self.registerPhone()
            }
            
            afterEach {
                self.deregisterPhone()
            }
            
            it("normal") {
            }
            
            it("double register") {
                self.registerPhone()
            }
            
            it("double deregister") {
                self.deregisterPhone()
            }
        }
        
        describe("phone dail") {
            beforeEach {
                self.registerPhone()
            }
            
            afterEach {
                self.deregisterPhone()
            }
            
            it("normal") {
                let mediaOption = MediaOption.audioVideo(local: MediaRenderView(), remote: MediaRenderView())
                var dailSuccess: Bool = false
                let user = self.fixture.createUser()
                
                self.phone.disableVideoCodecActivation()
                let call = self.phone.dial((user?.email.toString())!, option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call: call)
            }
            
            it("audio only") {
                let mediaOption = MediaOption.audioOnly
                var dailSuccess: Bool = false
                let user = self.fixture.createUser()
                
                let call = self.phone.dial((user?.email.toString())!, option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call: call)
            }
            
            it("normal with sip address") {
                let mediaOption = MediaOption.audioVideo(local: MediaRenderView(), remote: MediaRenderView())
                var dailSuccess: Bool = false
                
                self.phone.disableVideoCodecActivation()
                let call = self.phone.dial("sip:9995839764@sip.tropo.com", option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call: call)
            }
            
            it("audio only with sip address") {
                let mediaOption = MediaOption.audioOnly
                var dailSuccess: Bool = false
                let call = self.phone.dial("sip:9995839764@sip.tropo.com", option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call: call)
            }
        }
        
    }
}
