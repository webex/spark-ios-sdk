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
import XCTest
@testable import SparkSDK
@available (iOS 11.2,*)
class ScreenShareTests: XCTestCase {
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
        super.setUp()
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
        super.tearDown()
    }
    
    func testLocalScreenShareAndRelease() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.startSharing() {
                error in
                XCTAssertNil(error)
                self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
            }
            
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 2
            var sendingFlag = true
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.sendingScreenShare == sendingFlag)
                    if sendingFlag == true {
                        self.call?.stopSharing() {
                            error in
                            XCTAssertNil(error)
                            self.call?.update(model: FakeCallModelHelper.releaseLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                        sendingFlag = false
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            
            waitForExpectations(timeout: 8) { error in
                XCTAssertNil(error, "on connected time out")
            }
        }
    }
    
    func testLocalReplaceOtherScreenShare() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            
            self.call?.update(model: FakeCallModelHelper.grantedScreenShareCallModel(callModel: callmodel, shareUser: user))
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 4
            var remoteSendingFlag = true
            var sendingFlag = true
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.sendingScreenShare == sendingFlag)
                    if sendingFlag == true {
                        self.call?.stopSharing() {
                            error in
                            XCTAssertNil(error)
                            self.call?.update(model: FakeCallModelHelper.releaseLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                        sendingFlag = false
                    }
                    expect.fulfill()
                    break
                case .remoteSendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == remoteSendingFlag)
                    XCTAssertTrue(self.call?.remoteSendingScreenShare == remoteSendingFlag)
                    XCTAssertTrue(self.call?.receivingScreenShare == true)
                    if remoteSendingFlag == true {
                        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                        self.call?.startSharing() {
                            error in
                            XCTAssertNil(error)
                            
                            self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                        remoteSendingFlag = false
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            
            
            waitForExpectations(timeout: 8) { error in
                XCTAssertNil(error, "on onMediaChanged timeout")
            }
        }
    }
    
    
    func testOtherReplaceLocalScreenShare() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.startSharing() {
                error in
                XCTAssertNil(error)
                
                self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
            }
            
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 4
            var remoteSendingFlag = true
            var sendingFlag = true
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.sendingScreenShare == sendingFlag)
                    if sendingFlag == true {
                        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                        self.call?.update(model: FakeCallModelHelper.grantedScreenShareCallModel(callModel: callmodel, shareUser: user))
                        sendingFlag = false
                    }
                    expect.fulfill()
                    break
                case .remoteSendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == remoteSendingFlag)
                    XCTAssertTrue(self.call?.remoteSendingScreenShare == remoteSendingFlag)
                    XCTAssertTrue(self.call?.receivingScreenShare == true)
                    if remoteSendingFlag == true {
                        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                        self.call?.update(model: FakeCallModelHelper.releaseScreenShareCallModel(callModel: callmodel, shareUser: user))
                        
                        remoteSendingFlag = false
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            
            
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "on onMediaChanged timeout")
            }
        }
    }
    
    func testLocalScreenShareTwice() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.startSharing() {
                error in
                XCTAssertNil(error)
                self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
            }
            
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 4
            var sendingFlag = true
            var shareCount = 1
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.sendingScreenShare == sendingFlag)
                    if sendingFlag == true{
                        self.call?.stopSharing() {
                            error in
                            XCTAssertNil(error)
                            self.call?.update(model: FakeCallModelHelper.releaseLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                        sendingFlag = false
                    }
                    else if sendingFlag == false && shareCount == 1{
                        self.call?.startSharing() {
                            error in
                            XCTAssertNil(error)
                            self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                        shareCount = shareCount + 1
                        sendingFlag = true
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            
            waitForExpectations(timeout: 8) { error in
                XCTAssertNil(error, "on connected time out")
            }
        }
    }
    
    func testLocalShareAfterRemoteRelease() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            
            self.call?.update(model: FakeCallModelHelper.grantedScreenShareCallModel(callModel: callmodel, shareUser: user))
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 4
            var remoteSendingFlag = true
            var sendingFlag = true
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.sendingScreenShare == sendingFlag)
                    if sendingFlag == true {
                        self.call?.stopSharing() {
                            error in
                            XCTAssertNil(error)
                            self.call?.update(model: FakeCallModelHelper.releaseLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                        sendingFlag = false
                    }
                    expect.fulfill()
                    break
                case .remoteSendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == remoteSendingFlag)
                    XCTAssertTrue(self.call?.remoteSendingScreenShare == remoteSendingFlag)
                    XCTAssertTrue(self.call?.receivingScreenShare == true)
                    if remoteSendingFlag == true {
                        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                        self.call?.update(model: FakeCallModelHelper.releaseScreenShareCallModel(callModel: callmodel, shareUser: user))
                        remoteSendingFlag = false
                    } else {
                        self.call?.startSharing() {
                            error in
                            XCTAssertNil(error)
                            
                            self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            
            
            waitForExpectations(timeout: 8) { error in
                XCTAssertNil(error, "on onMediaChanged timeout")
            }
        }
    }
    
    func testRemoteShareAfterLocalRelease() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.startSharing() {
                error in
                XCTAssertNil(error)
                
                self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
            }
            
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 4
            var remoteSendingFlag = true
            var sendingFlag = true
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.sendingScreenShare == sendingFlag)
                    if sendingFlag == true {
                        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                        self.call?.stopSharing() {
                            error in
                            XCTAssertNil(error)
                            self.call?.update(model: FakeCallModelHelper.releaseLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                        }
                        sendingFlag = false
                    } else {
                        self.call?.update(model: FakeCallModelHelper.grantedScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                    }
                    expect.fulfill()
                    break
                case .remoteSendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == remoteSendingFlag)
                    XCTAssertTrue(self.call?.remoteSendingScreenShare == remoteSendingFlag)
                    XCTAssertTrue(self.call?.receivingScreenShare == true)
                    if remoteSendingFlag == true {
                        
                        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
                        self.call?.update(model: FakeCallModelHelper.releaseScreenShareCallModel(callModel: callmodel, shareUser: user))
                        
                        remoteSendingFlag = false
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, "on onMediaChanged timeout")
            }
        }
    }
    
    func testLocalShareWithoutScreenShareAbility() {
        self.call = mockCallWithoutScreenShare()
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.startSharing() {
                error in
                XCTAssertNotNil(error)
            }
        }
        
    }
    
    func testLocalShareTwiceWithoutRelease() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.startSharing() {
                error in
                XCTAssertNil(error)
                self.call?.update(model: FakeCallModelHelper.grantedLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
            }
            
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 2
            var sendingFlag = true
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(let isSending):
                    XCTAssertTrue(isSending == sendingFlag)
                    XCTAssertTrue(self.call?.sendingScreenShare == sendingFlag)
                    if sendingFlag == true {
                        self.call?.startSharing() {
                            error in
                            XCTAssertNotNil(error)
                            self.call?.stopSharing() {
                                error in
                                XCTAssertNil(error)
                                self.call?.update(model: FakeCallModelHelper.releaseLocalScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
                            }
                        }
                        sendingFlag = false
                    }
                    expect.fulfill()
                    break
                default:
                    break
                }
            }
            
            waitForExpectations(timeout: 8) { error in
                XCTAssertNil(error, "on connected time out")
            }
        }
    }
    
    func testLocalShareInUnconnectedCall() {
        if let callmodel = self.call?.model {
            self.fakeCallClient?.callModel = callmodel
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.startSharing() {
                error in
                XCTAssertNotNil(error)
            }
        }
    }
    
    func testLocalReleaseShareWithoutScreenShareAbility() {
        self.call = mockCallWithoutScreenShare()
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.stopSharing() {
                error in
                XCTAssertNotNil(error)
            }
        }
    }
    
    func testLocalReleaseShareBeforeSharing() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.stopSharing() {
                error in
                XCTAssertNotNil(error)
            }
        }
    }
    
    func testScreenShareFromSelfWithOtherDevice() {
        if let callmodel = self.call?.model,let user = self.remoteUser {
            self.call?.update(model: FakeCallModelHelper.answerCallModel(callModel: callmodel, answerUser: user))
            self.fakeCallClient?.callModel = self.call?.model
            XCTAssert(self.call?.sendingScreenShare == false)
            self.call?.update(model: FakeCallModelHelper.grantedScreenShareCallModel(callModel: (self.call?.model)!, shareUser: self.fixture.selfUser))
            let expect = expectation(description: "on onMediaChanged")
            expect.expectedFulfillmentCount = 1
            self.call?.onMediaChanged = {
                event in
                switch event {
                case .sendingScreenShare(_):
                    break
                case .remoteSendingScreenShare(_):
                    self.call?.stopSharing() {
                        error in
                        XCTAssertNotNil(error)
                        expect.fulfill()
                    }
                    break
                default:
                    break
                }
            }
            
            waitForExpectations(timeout: 8) { error in
                XCTAssertNil(error, "on connected time out")
            }
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
    
    private func mockCall() -> Call? {
        if let user = self.fixture.createUser() {
            self.remoteUser = user
            let callModel = FakeCallModelHelper.dialCallModel(caller: self.fixture.selfUser, callee: user)
            let mediaSession = MediaSessionWrapper()
            mediaSession.prepare(option: MediaOption.audioVideoScreenShare(video: (local:self.localView!,remote:self.remoteView!), screenShare: self.screenShareView!, applicationGroupIdentifier: "test.applicationGroupIdentifier"), phone: self.phone)
            let call = Call(model: callModel, device: (self.fakeDeviceService?.device)!, media: mediaSession, direction: Call.Direction.outgoing, group: false, uuid: nil)
            return call
        }
        
        return nil
    }
    
    private func mockCallWithoutScreenShare() -> Call? {
        if let user = self.fixture.createUser() {
            self.remoteUser = user
            let callModel = FakeCallModelHelper.dialCallModel(caller: self.fixture.selfUser, callee: user)
            let mediaSession = MediaSessionWrapper()
            mediaSession.prepare(option: MediaOption.audioVideo(local: self.localView!, remote: self.remoteView!), phone: self.phone)
            let call = Call(model: callModel, device: (self.fakeDeviceService?.device)!, media: mediaSession, direction: Call.Direction.outgoing, group: false, uuid: nil)
            return call
        }
        
        return nil
    }
}
