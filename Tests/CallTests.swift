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


import Foundation
import XCTest
@testable import SparkSDK

class CallTests: XCTestCase {
    private var fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private var remoteUser: TestUser? = nil
    private var call:Call?
    private var phone: Phone!
    private var localView:MediaRenderView?
    private var remoteView:MediaRenderView?
    private var screenShareView:MediaRenderView?
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
        screenShareView = MediaRenderView()
        self.call = mockCall()
    }
    
    override func tearDown() {
        self.call = nil
        XCTAssertTrue(deregisterPhone())
        localView = nil
        remoteView = nil
    }
    
    func testSendDTMFSuccess() {
        self.enabelDTMF()
        XCTAssertTrue(self.call?.sendingDTMFEnabled == true)
        
        let expect = expectation(description: "send DTMF")
        self.call?.send(dtmf: "123") { error in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "send DTMF time out")
        }
        
    }
    
    func testSendDTMFFailed() {
        self.enabelDTMF()
        self.fakeCallClient?.enableServerReturnError = true
        XCTAssertTrue(self.call?.sendingDTMFEnabled == true)
        
        let expect = expectation(description: "send DTMF")
        self.call?.send(dtmf: "123") { error in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "send DTMF time out")
        }
    }
    
    func testDisabelDTMF() {
        XCTAssertTrue(self.call?.sendingDTMFEnabled == false)
        
        let expect = expectation(description: "send DTMF")
        self.call?.send(dtmf: "123") { error in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "send DTMF time out")
        }
    }
    
    func testDTMFMissingUrl() {
        self.mockMissingUrlCall()
        XCTAssertTrue(self.call?.sendingDTMFEnabled == false)
        
        let expect = expectation(description: "send DTMF")
        self.call?.send(dtmf: "123") { error in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "send DTMF time out")
        }
    }
    
    func testOnRinging() {
        let expect = expectation(description: "on ringing")
        expect.expectedFulfillmentCount = 2
        self.call?.onRinging = {
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "on ringing time out")
        }
    }
    
    func testOnConnected() {
        let expect = expectation(description: "on connected")
        expect.expectedFulfillmentCount = 1
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
        
            self.call?.onConnected = {
                expect.fulfill()
            }
        
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "on connected time out")
            }
        }
    }
    
    func testCallMediaParameters() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            let expect = expectation(description: "on connected")
            
            self.call?.onConnected = {
                XCTAssertTrue(self.call?.sendingAudio == true)
                XCTAssertTrue(self.call?.sendingVideo == true)
                XCTAssertTrue(self.call?.receivingAudio == true)
                XCTAssertTrue(self.call?.receivingVideo == true)
                XCTAssertTrue(self.call?.remoteSendingAudio == true)
                XCTAssertTrue(self.call?.remoteSendingVideo == true)
                XCTAssertTrue(self.call?.videoRenderViews?.local == self.localView)
                XCTAssertTrue(self.call?.videoRenderViews?.remote == self.remoteView)
                XCTAssertTrue(self.call?.screenShareRenderView == self.screenShareView)
                XCTAssertTrue(self.call?.remoteSendingScreenShare == false)
                XCTAssertTrue(self.call?.isSpeaker == true)
                XCTAssertTrue(self.call?.facingMode == Phone.FacingMode.user)
                XCTAssertTrue(self.call?.receivingScreenShare == true)
                expect.fulfill()
            }
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "on connected time out")
            }
        }
    }
    
    func testScreenShareAndRelease() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.call?.update(model: FakeCallModelHelper.grantedScreenShareCallModel(callModel: callmodel, shareUser: user))
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 2
            var sendingFlag = true
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .remoteSendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.remoteSendingScreenShare == sendingFlag)
                    XCTAssertTrue(self.call?.receivingScreenShare == true)
                    if sendingFlag == true {
                        self.call?.update(model: FakeCallModelHelper.releaseScreenShareCallModel(callModel: callmodel, shareUser: user))
                        sendingFlag = false
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            
            
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "on connected time out")
            }
        }
    }
    
    private func mockCall() -> Call? {
        if let user = self.fixture.createUser() {
            self.remoteUser = user
            let callModel = FakeCallModelHelper.dialCallModel(caller: self.fixture.selfUser, callee: user)
            let mediaSession = MediaSessionWrapper()
            mediaSession.prepare(option: MediaOption.audioVideoScreenShare(video: (local:self.localView!,remote:self.remoteView!), screenShare: self.screenShareView!), phone: self.phone)
            let call = Call(model: callModel, device: (self.fakeDeviceService?.device)!, media: mediaSession, direction: Call.Direction.outgoing, group: false, uuid: nil)
            return call
        }
        
        return nil
    }
    
    private func enabelDTMF() {
        if let enabelDTMFCall = self.call {
            var callModel = enabelDTMFCall.model
            var mySelf = callModel.myself
            mySelf?.enableDTMF = true
            callModel.setMyself(newParticipant: mySelf)
            enabelDTMFCall.model = callModel
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
    
    private func mockMissingUrlCall() {
        guard self.call != nil else {
            return
        }
        
        if var mySelf = self.call?.model.myself {
            mySelf.url = nil
            self.call?.model.setMyself(newParticipant: mySelf)
        }
        
    }
    
}
