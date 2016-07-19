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

class PhoneSpec: QuickSpec {

    private func registerPhone() {
        var registerSuccess: Bool = false
        Spark.phone.register() {
            registerSuccess = $0
        }
        expect(registerSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
    }
    
    private func deregisterPhone() {
        var deregisterSuccess: Bool = false
        Spark.phone.deregister() {
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
            Spark.initWith(accessToken: Config.selfUser.token!)
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
                let mediaOption = MediaOption.AudioVideo(local: MediaRenderView(), remote: MediaRenderView())
                var dailSuccess: Bool = false
                let user = TestUserFactory.sharedInstance.createUser()
                
                Spark.phone.disableVideoCodecActivation()
                let call = Spark.phone.dial((user.email?.toString())!, option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call)
            }
            
            it("audio only") {
                let mediaOption = MediaOption.AudioOnly
                var dailSuccess: Bool = false
                let user = TestUserFactory.sharedInstance.createUser()
                
                let call = Spark.phone.dial((user.email?.toString())!, option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call)
            }
            
            it("normal with sip address") {
                let mediaOption = MediaOption.AudioVideo(local: MediaRenderView(), remote: MediaRenderView())
                var dailSuccess: Bool = false
                
                Spark.phone.disableVideoCodecActivation()
                let call = Spark.phone.dial("sip:9995839764@sip.tropo.com", option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call)
            }
            
            it("audio only with sip address") {
                let mediaOption = MediaOption.AudioOnly
                var dailSuccess: Bool = false
                let call = Spark.phone.dial("sip:9995839764@sip.tropo.com", option: mediaOption) {
                    dailSuccess = $0
                }
                expect(dailSuccess).toEventually(beTrue(), timeout: Config.TestcasePendingCheckTimeout, pollInterval: Config.TestcasePendingCheckPollInterval)
                
                self.hangupCall(call)
            }
        }
        
    }
}