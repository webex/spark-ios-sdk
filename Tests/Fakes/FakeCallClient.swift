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

import Foundation
@testable import SparkSDK

class FakeCallClient: CallClient {
    var callModel: CallModel?
    
    var selfUser: TestUser?
    var otherParticipants: [TestUser]?
//    var callerUser: TestUser?
//    var calleeUser: TestUser?
    var enableFetchCall: Bool = false
    var isRoomCall: Bool = false
    var enableServerReturnError: Bool = false
    
    
    var illegalType:FakeCallModelHelper.CallIllegalStatusType? = nil
    
    override init(authenticator: Authenticator) {
        super.init(authenticator: authenticator)
    }
    
    override func create(_ toAddress: String, by device: Device, localMedia: MediaModel, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
    
        if let caller = selfUser,let callee = otherParticipants?.first {
            
            if let type = self.illegalType {
                self.callModel = FakeCallModelHelper.dialIllegalCallModel(caller: caller, callee: callee, type: type)
            }
            else {
                self.callModel = FakeCallModelHelper.dialCallModel(caller: caller, callee: callee)
            }
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
        
    }
    
    override func leave(_ participantUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        if let oldModel = self.callModel,let hanupUser = selfUser {
            self.callModel = FakeCallModelHelper.hangUpCallModel(callModel: oldModel,hanupUser: hanupUser)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
        
        
    }
    
    override func fetch(by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<[CallModel]>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if enableFetchCall ,let caller = self.otherParticipants?.first,let callee = selfUser {
            self.otherParticipants?.append(callee)
            self.callModel = FakeCallModelHelper.initCallModel(caller: caller, allParticipantUsers: self.otherParticipants!, selfUser: callee)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success([self.callModel!])))
        }
        else {
        completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success([])))
        }
    }
    
    override func join(_ callUrl: String, by device: Device, localMedia: MediaModel, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if isRoomCall,let caller = selfUser,var callees = self.otherParticipants {
            callees.append(caller)
            self.callModel = FakeCallModelHelper.initCallModel(caller: caller, allParticipantUsers: callees, selfUser: caller)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
        else if let oldModel = self.callModel,let answerUser = selfUser {
            self.callModel = FakeCallModelHelper.answerCallModel(callModel: oldModel, answerUser: answerUser)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        
        }
    }
    
    override func decline(_ callUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if let oldModel = self.callModel,let declineUser = selfUser {
            self.callModel = FakeCallModelHelper.declineCallModel(callModel: oldModel, declineUser: declineUser)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
    }
    
    override func alert(_ callUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if let oldModel = self.callModel,let alertUser = selfUser {
            self.callModel = FakeCallModelHelper.alertCallModel(callModel: oldModel, alertUser: alertUser)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
    }
    
    override func update(_ mediaUrl: String, by mediaID: String, by device: Device, localMedia: MediaModel, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if let oldModel = self.callModel,let updateUser = selfUser {
            self.callModel = FakeCallModelHelper.updateMediaCallModel(callModel: oldModel, updateUser: updateUser,localMedia:localMedia)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
    }
    
    override func sendDtmf(_ participantUrl: String, by device: Device, correlationId: Int, events: String, volume: Int? = nil, durationMillis: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "sendDtmf error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success("success")))
    }
    
    override func updateMediaShare(_ mediaShare: MediaShareModel, by device: Device, mediaShareUrl: String, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "updateMediaShare error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if let oldModel = self.callModel {
//            self.callModel = FakeCallModelHelper.updateMediaCallModel(callModel: oldModel, updateUser: updateUser,localMedia:localMedia)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(oldModel.toJSONString())))
        }
    }
    
}



