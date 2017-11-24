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
    private var localView:MediaRenderView?
    private var remoteView:MediaRenderView?
    private var fakeCallClient:FakeCallClient?
    private var fakeWebSocketService:FakeWebSocketService?
    private var fakeDeviceService:FakeDeviceService?
    private var fakeConversationClient:FakeConversationClient?
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        let authenticator = fixture.spark.authenticator
        
        self.fakeDeviceService = FakeDeviceService(authenticator: authenticator)
        self.fakeCallClient = FakeCallClient(authenticator: authenticator)
        self.fakeCallClient?.selfUser = fixture.selfUser
        self.fakeWebSocketService = FakeWebSocketService(authenticator: authenticator)
        self.fakeConversationClient = FakeConversationClient(authenticator: authenticator)
        let metricsEngine = MetricsEngine(authenticator: authenticator, service: self.fakeDeviceService!)
        phone = Phone(authenticator: authenticator, devices: self.fakeDeviceService!, reachability: FakeReachabilityService(authenticator: authenticator, deviceService: self.fakeDeviceService!), client: self.fakeCallClient!, conversations: self.fakeConversationClient!, metrics: metricsEngine, prompter: H264LicensePrompter(metrics: metricsEngine), webSocket: self.fakeWebSocketService!)
        phone.disableVideoCodecActivation()
        XCTAssertNotNil(phone)
        
        XCTAssertTrue(registerPhone())
        localView = MediaRenderView()
        remoteView = MediaRenderView()
    }
    
    override func tearDown() {
        XCTAssertTrue(deregisterPhone())
        localView = nil
        remoteView = nil
    }
    
    func testWhenRegisterAndDeregisterPhoneThenBothSucceed() {
        // Tests that basic setup and teardown work without issue.
    }
    
    func testWhenRegisterAndDeregisterPhoneThenBothFailed() {
        _ = self.deregisterPhone()
        
        self.fakeDeviceService!.disableRegister = true
        self.fakeDeviceService!.disableDeregister = true
        XCTAssertFalse(self.registerPhone())
        XCTAssertFalse(self.deregisterPhone())
        
    }
    
    func testWhenRegisterPhoneTwiceThenBothSucceed() {
        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
        XCTAssertTrue(registerPhone())
    }
    
    func testWhenDeregisterPhoneTwiceThenBothSuceed() {
        XCTAssertTrue(deregisterPhone())
        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
    }
    
    func testWhenDialThenReturnsSuccessAndHangsUp() {
        if let user = fixture.createUser() {
            let mediaOption = MediaOption.audioVideo(local: localView!, remote: remoteView!)
            let call = dialCall(dialUser: user, mediaOption: mediaOption)
            XCTAssertNotNil(call)
            XCTAssertTrue(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testWhenDialThenReturnsSuccessAndHangsUpFailed() {
        if let user = fixture.createUser() {
            let mediaOption = MediaOption.audioVideo(local: localView!, remote: remoteView!)
            let call = dialCall(dialUser: user, mediaOption: mediaOption)
            XCTAssertNotNil(call)
            self.fakeCallClient?.enableServerReturnError = true
            XCTAssertFalse(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testWhenDialRoomThenReturnsSuccessAndHangsUp() {
        if let user = fixture.createUser() {
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            let expect = expectation(description: "room create")
            self.fixture.spark.rooms.create(title: "title") {
                response in
                switch response.result {
                case .success(let room):
                    let mediaOption = MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)
                    self.phone.disableVideoCodecActivation()
                    Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                    
                    self.fakeCallClient?.otherParticipants = [user]
                    self.fakeCallClient?.isRoomCall = true
                    self.phone.dial(room.id!, option: mediaOption) { result in
                        let call = result.data
                        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                        XCTAssertNotNil(call)
                        call?.hangup() { error in
                            XCTAssertTrue(error == nil)
                            expect.fulfill()
                        }
                        
                    }
                    
                    break
                case .failure(_):
                    XCTFail("Unable to create room")
                    break
                }
            }
            waitForExpectations(timeout:20) { error in
                XCTAssertNil(error, "Call acknowledge timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testDialAndReturnsInIllegalStatusCall() {
        if let user = fixture.createUser() {
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            let expect = expectation(description: "room create")
            
            
            let mediaOption = MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)
            self.phone.disableVideoCodecActivation()
            
            
            self.fakeCallClient?.otherParticipants = [user]
            self.fakeCallClient?.illegalType = FakeCallModelHelper.CallIllegalStatusType.isRemoteLeft
            self.phone.dial(user.email.toString(), option: mediaOption) { result in
                
                XCTAssertNotNil(result.error)
                expect.fulfill()
                Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            }
            
            
            waitForExpectations(timeout:20) { error in
                XCTAssertNil(error, "Call acknowledge timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testDialReturnMissingCallUrl() {
        if let user = fixture.createUser() {
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            let expect = expectation(description: "room create")
            let mediaOption = MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)
            self.fakeCallClient?.otherParticipants = [user]
            self.fakeCallClient?.illegalType = FakeCallModelHelper.CallIllegalStatusType.missingCallUrl
            
            self.phone.dial(user.email.toString(), option: mediaOption) { result in
                Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                XCTAssertNotNil(result.error)
                expect.fulfill()
            }
            waitForExpectations(timeout:20) { error in
                XCTAssertNil(error, "Call acknowledge timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
//    func testDialReturnServerError() {
//        if let user = fixture.createUser() {
//            let expect = self.expectation(description: "dial call")
//            let mediaOption = MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)
//            self.fakeCallClient?.enableServerReturnError = true
//            self.phone.dial(user.email.toString(), option: mediaOption) { result in
//                XCTAssertNotNil(result.error)
//                
//                expect.fulfill()
//            }
//            self.waitForExpectations(timeout:20) { error in
//                XCTAssertNil(error, "Call dial timed out")
//            }
//        } else {
//            XCTFail("Unable to create user")
//        }
//        
//    }
    
    
    //    func testWhenDialRoomThenReturnsConversationFailed() {
    //
    //        let expect = expectation(description: "room create")
    //
    //        let mediaOption = MediaOption.audioVideo(local: MediaRenderView(), remote: MediaRenderView())
    //        self.phone.disableVideoCodecActivation()
    //
    //        self.fakeConversationClient?.disabelConversation = true
    //        self.phone.dial(Config.FakeRoomId, option: mediaOption) { result in
    //            XCTAssertNotNil(result.error)
    //            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
    //            expect.fulfill()
    //        }
    //
    //        waitForExpectations(timeout:20) { error in
    //            XCTAssertNil(error, "Call acknowledge timed out")
    //        }
    //    }
    
    
    func testRejectTheOutgoingCall() {
        if let user = fixture.createUser() {
            let mediaOption = MediaOption.audioVideo(local: localView!, remote: remoteView!)
            let call = dialCall(dialUser: user, mediaOption: mediaOption)
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call reject")
            call?.reject() {
                error in
                XCTAssertNotNil(error)
                expect.fulfill()
            }
            waitForExpectations(timeout:5) { error in
                XCTAssertNil(error, "Call reject timed out")
            }
            XCTAssertTrue(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    
    
    func testDialAndAlert() {
        if let user = fixture.createUser() {
            let mediaOption = MediaOption.audioVideo(local: localView!, remote: remoteView!)
            let call = dialCall(dialUser:user, mediaOption: mediaOption)
            XCTAssertNotNil(call)
            
            let expect = expectation(description: "Call acknowledge")
            call?.acknowledge() { error in
                XCTAssertNotNil(error)
                expect.fulfill()
            }
            waitForExpectations(timeout:5) { error in
                XCTAssertNil(error, "Call acknowledge timed out")
            }
            
            XCTAssertTrue(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testAnswerOutgoingCall() {
        if let user = fixture.createUser() {
            let mediaOption = MediaOption.audioVideo(local: localView!, remote: remoteView!)
            let call = dialCall(dialUser:user, mediaOption: mediaOption)
            XCTAssertNotNil(call)
            
            let expect = expectation(description: "Call answer")
            call?.answer(option: mediaOption) { error in
                XCTAssertNotNil(error)
                expect.fulfill()
            }
            waitForExpectations(timeout:5) { error in
                XCTAssertNil(error, "Call answer timed out")
            }
            
            XCTAssertTrue(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    func testWhenDialWithAudioOnlyThenReturnsSuccessAndHangsUp() {
        if let user = fixture.createUser() {
            let call = dialCall(dialUser:user, mediaOption: MediaOption.audioOnly())
            XCTAssertNotNil(call)
            XCTAssertTrue(hangupCall(call: call!))
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    //    func testDialWhenUnRegisterFailed() {
    //        _ = self.deregisterPhone()
    //        if let user = fixture.createUser() {
    //            Thread.sleep(forTimeInterval: Config.TestcasePendingMediaInit)
    //            let expect = expectation(description: "Call dial")
    //            self.fakeCallClient?.calleeUser = user
    //
    //
    //            phone.dial(user.email.toString(), option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) { result in
    //                XCTAssertNotNil(result.data)
    //                Thread.sleep(forTimeInterval: Config.TestcasePendingMediaInit)
    //                Thread.sleep(forTimeInterval: Config.TestcasePendingMediaInit)
    //                expect.fulfill()
    //            }
    //
    //            waitForExpectations(timeout: 20) { error in
    //                XCTAssertNil(error, "Phone dial timed out")
    //            }
    //        } else {
    //            XCTFail("Unable to create user")
    //        }
    //    }
    
    
    func testReceivedIncomingCallAndReject() {
        if let user = fixture.createUser() {
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect1 = expectation(description: "Call onDisconnected")
            call?.reject() { error in
                XCTAssertTrue(error == nil)
                expect1.fulfill()
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call?.onDisconnected = { reason in
                switch reason {
                case .localDecline:
                    XCTAssertNotNil(reason)
                    
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
                
            }
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testReceivedIncomingCallAndRejectFailed() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect1 = expectation(description: "Call onDisconnected")
            self.fakeCallClient?.enableServerReturnError = true
            call?.reject() { error in
                XCTAssertNotNil(error)
                expect1.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    func testAcceptIncomingCallAndHangsUp() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call answer")
            call?.onConnected = {
                error in
                
                call?.hangup() { error in
                    XCTAssertTrue(error == nil)
                    expect1.fulfill()
                }
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                    
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
                
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testAcceptIncomingCallFailed() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            self.fakeCallClient?.enableServerReturnError = true
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertNotNil(error)
                expect.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    func testAcceptConnectedCallAndHangsUp() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call onConnected")
            call?.onConnected = {
                error in
                call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                    error in
                    XCTAssertNotNil(error)
                    call?.hangup() { error in
                        XCTAssertTrue(error == nil)
                        expect1.fulfill()
                    }
                }
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                    
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testRejectConnectedCallAndHangsUp() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call onConnected")
            call?.onConnected = {
                error in
                call?.reject() {
                    error in
                    XCTAssertNotNil(error)
                    call?.hangup() { error in
                        XCTAssertTrue(error == nil)
                        expect1.fulfill()
                    }
                }
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    func testRejectMissingCallUrl() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call reject")
            call?.model.setLocusUrl(newLocusUrl: nil)
            call?.reject() {
                error in
                XCTAssertNotNil(error)
                expect.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone reject timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    func testAcceptDisconnectedCall() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call onConnected")
            call?.onConnected = {
                error in
                call?.hangup() { error in
                    XCTAssertTrue(error == nil)
                    expect1.fulfill()
                }
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            let expect3 = expectation(description: "Call onDisconnected answer")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                    call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                        error in
                        XCTAssertNotNil(error)
                        expect3.fulfill()
                    }
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testRejectDisconnectedCall() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call onConnected")
            call?.onConnected = {
                error in
                call?.hangup() { error in
                    XCTAssertTrue(error == nil)
                    expect1.fulfill()
                }
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            let expect3 = expectation(description: "Call onDisconnected reject")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                    call?.reject() {
                        error in
                        XCTAssertNotNil(error)
                        expect3.fulfill()
                    }
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testAlertConnectedCallAndHangsUp() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call hangup")
            call?.onConnected = {
                error in
                call?.acknowledge() {
                    error in
                    XCTAssertNotNil(error)
                    call?.hangup() { error in
                        XCTAssertTrue(error == nil)
                        expect1.fulfill()
                    }
                }
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    func testAcceptSecondIncomingCallAndHangsUp() {
        if let user1 = fixture.createUser(),let user2 = fixture.createUser() {
            let call1 = waitingCall(dialUser: user1, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call1)
            
            let expect1 = self.expectation(description: "Call2 incoming")
            var call2: Call? = nil
            
            self.phone.onIncoming = { incomingCall in
                call2 = incomingCall
                XCTAssertNotNil(call2)
                call2?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) { error in
                    XCTAssertNotNil(error)
                    call1?.hangup() { error in
                        XCTAssertTrue(error == nil)
                        expect1.fulfill()
                    }
                }
            }
            self.fakeCallClient?.callModel = call1?.model
            
            let expect = expectation(description: "Call answer")
            call1?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            
            call1?.onConnected = {
                self.fakeWebSocketService?.sendOnincomingCall(caller: user2, callee: self.fixture.selfUser)
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call1?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testAlertSecondIncomingCallAndHangsUp() {
        if let user1 = fixture.createUser(),let user2 = fixture.createUser() {
            let call1 = waitingCall(dialUser: user1, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call1)
            
            let expect1 = self.expectation(description: "Call2 incoming")
            var call2: Call? = nil
            
            self.phone.onIncoming = { incomingCall in
                call2 = incomingCall
                XCTAssertNotNil(call2)
                
                call2?.acknowledge() { error in
                    XCTAssertNotNil(error)
                    call1?.hangup() { error in
                        XCTAssertTrue(error == nil)
                        expect1.fulfill()
                    }
                }
            }
            self.fakeCallClient?.callModel = call1?.model
            
            let expect = expectation(description: "Call answer")
            call1?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            
            call1?.onConnected = {
                self.fakeWebSocketService?.sendOnincomingCall(caller: user2, callee: self.fixture.selfUser)
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call1?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testAcceptIncomingCallAndDial() {
        if let user = fixture.createUser() {
            let call1 = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call1)
            self.fakeCallClient?.callModel = call1?.model
            let expect = expectation(description: "Call answer")
            call1?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call dial")
            call1?.onConnected = {
                self.fakeCallClient?.otherParticipants = [user]
                self.phone.dial(user.email.toString(), option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) { result in
                    switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                    default :
                        XCTFail()
                    }
                    expect1.fulfill()
                    call1?.hangup() {
                        error in
                        XCTAssertTrue(error == nil)
                    }
                }
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call1?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testACKIncomingCall() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call ACK")
            call?.acknowledge() {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testACKIncomingCallFailed() {
        if let user = fixture.createUser() {
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call ACK")
            self.fakeCallClient?.enableServerReturnError = true
            call?.acknowledge() {
                error in
                XCTAssertNotNil(error)
                expect.fulfill()
            }
            
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    func testApplicationLifeCycle() {
        if let user = fixture.createUser() {
            self.fakeCallClient?.otherParticipants = [user]
            self.fakeCallClient?.enableFetchCall = true
            NotificationCenter.default.post(name: .UIApplicationDidEnterBackground, object: nil)
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil)
            let expect = expectation(description: "Call incoming")
            self.phone.onIncoming = {
                call in
                XCTAssertNotNil(call)
                call.reject() {
                    error in
                    XCTAssertNil(error)
                    expect.fulfill()
                }
            }
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "Phone incoming timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testPreview() {
        self.phone.startPreview(view: self.localView!)
        Thread.sleep(forTimeInterval: Config.TestcasePendingMediaInit)
        self.phone.stopPreview()
        Thread.sleep(forTimeInterval: Config.TestcasePendingMediaInit)
    }
    
    func testMediaUpdate() {
        if let user = fixture.createUser() {
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call mute video")
            call?.onConnected = {
                error in
                call?.sendingVideo = false
                FakeMediaSession.stubMediaChangeNotification(eventType: .sendingVideo(false),call: call!)
            }
            
            call?.onMediaChanged = {
                event in
                switch event {
                case.sendingVideo(let isSending):
                    XCTAssertFalse(isSending)
                default:
                    XCTFail("unexcept media changed type")
                    break
                }
                
                call?.hangup() {
                    error in
                    XCTAssertTrue(error == nil)
                }
                expect1.fulfill()
            }
            
            let expect2 = expectation(description: "Call onDisconnected")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
                expect2.fulfill()
                
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testMediaUpdateFailed() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call mute video")
            call?.onConnected = {
                error in
                call?.sendingVideo = false
                self.fakeCallClient?.enableServerReturnError = true
                FakeMediaSession.stubMediaChangeNotification(eventType: .sendingVideo(false),call: call!)
            }
            
            call?.onMediaChanged = {
                event in
                switch event {
                case.sendingVideo(let isSending):
                    XCTAssertFalse(isSending)
                default:
                    XCTFail("unexcept media changed type")
                    break
                }
                expect1.fulfill()
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    
    //    func testMediaUpdateWhenCallMedia() {
    //        if let user = fixture.createUser() {
    //            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
    //            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
    //            XCTAssertNotNil(call)
    //
    //            call?.sendingVideo = false
    //            FakeMediaSession.stubMediaChangeNotification(eventType: .sendingVideo(false),call: call!)
    //
    //            let expect1 = expectation(description: "Call mute video")
    //            call?.onMediaChanged = {
    //                event in
    //                switch event {
    //                case.sendingVideo(let isSending):
    //                    XCTAssertFalse(isSending)
    //                default:
    //                    XCTFail("unexcept media changed type")
    //                    break
    //                }
    //                expect1.fulfill()
    //            }
    //
    //            waitForExpectations(timeout: 15) { error in
    //                XCTAssertNil(error, "Phone hangup timed out")
    //            }
    //        } else {
    //            XCTFail("Unable to create user")
    //        }
    //    }
    
    
    func testHangsUpADisconnectedCall() {
        if let user = fixture.createUser() {
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call onConnected")
            call?.onConnected = {
                error in
                call?.hangup() { error in
                    XCTAssertTrue(error == nil)
                    expect1.fulfill()
                }
            }
            
            let expect2 = expectation(description: "Call hangup disconnected")
            call?.onDisconnected = { reason in
                switch reason {
                case .localLeft:
                    XCTAssertNotNil(reason)
                    call?.hangup() {
                        error in
                        XCTAssertNotNil(error)
                        expect2.fulfill()
                    }
                default:
                    XCTFail("unexcept disconnected reason")
                    break
                }
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
    }
    
    func testHangsUpAMissingUrlCall() {
        if let user = fixture.createUser() {
            Thread.sleep(forTimeInterval: Config.TestcaseInterval)
            let call = waitingCall(dialUser: user, mediaOption: MediaOption.audioVideo(renderViews: (local:self.localView!, remote: self.remoteView!)))
            XCTAssertNotNil(call)
            let expect = expectation(description: "Call answer")
            call?.answer(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!)) {
                error in
                XCTAssertTrue(error == nil)
                expect.fulfill()
            }
            let expect1 = expectation(description: "Call answer")
            call?.onConnected = {
                error in
                var mySelf = call?.model.myself
                mySelf?.url = nil
                call?.model.setMyself(newParticipant: mySelf)
                call?.hangup() { error in
                    XCTAssertNotNil(error)
                    expect1.fulfill()
                }
            }
            
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Phone hangup timed out")
            }
        } else {
            XCTFail("Unable to create user")
        }
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
    
    private func dialCall(dialUser: TestUser, mediaOption: MediaOption) -> Call? {
        let expect = expectation(description: "Call dial")
        var call:Call? = nil
        
        self.fakeCallClient?.otherParticipants = [dialUser]
        phone.dial(dialUser.email.toString(), option: mediaOption) { result in
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
    
    private func rejectCall(call: Call) -> Bool {
        var success = false
        
        let expect = expectation(description: "Call hangup")
        call.reject() { error in
            success = (error == nil)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone hangup timed out")
        }
        return success
    }
    
    private func waitingCall(dialUser:TestUser, mediaOption: MediaOption) -> Call? {
        let expect = expectation(description: "Call onIncoming")
        var call:Call? = nil
        
        phone.onIncoming = { incomingCall in
            call = incomingCall
            self.fakeCallClient?.callModel = call?.model
            expect.fulfill()
        }
        
        self.fakeWebSocketService?.sendOnincomingCall(caller: dialUser, callee: fixture.selfUser)
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone waiting timed out")
        }
        
        return call
    }
}
