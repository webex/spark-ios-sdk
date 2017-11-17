//
//  FakeCallClient.swift
//  SparkSDK
//
//  Created by panzh on 07/11/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
@testable import SparkSDK

class FakeCallClient: CallClient {
    var callModel: CallModel?
    var callerUser: TestUser?
    var calleeUser: TestUser?
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
        
        
        if let caller = callerUser,let callee = calleeUser {
            
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
        if let oldModel = self.callModel,let caller = self.callerUser {
            self.callModel = FakeCallModelHelper.hangUpCallModel(callModel: oldModel,hanupUser: caller)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
        
        
    }
    
    override func fetch(by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<[CallModel]>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if enableFetchCall ,let caller = self.callerUser,let callee = self.calleeUser {
            self.callModel = FakeCallModelHelper.initCallModel(caller: caller, allParticipantUsers: [caller,callee], selfUser: callee)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success([self.callModel!])))
            self.enableFetchCall = false
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
        
        if isRoomCall,let caller = self.callerUser,let callee = self.calleeUser {
            self.callModel = FakeCallModelHelper.initCallModel(caller: caller, allParticipantUsers: [caller,callee], selfUser: caller)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
        else if let oldModel = self.callModel,let caller = self.callerUser {
            self.callModel = FakeCallModelHelper.answerCallModel(callModel: oldModel, answerUser: caller)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        
        }
    }
    
    override func decline(_ callUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if let oldModel = self.callModel,let caller = self.callerUser {
            self.callModel = FakeCallModelHelper.answerCallModel(callModel: oldModel, answerUser: caller)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
    }
    
    override func alert(_ callUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if let oldModel = self.callModel,let caller = self.callerUser {
            self.callModel = FakeCallModelHelper.alertCallModel(callModel: oldModel, alertUser: caller)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
    }
    
    override func update(_ mediaUrl: String, by mediaID: String, by device: Device, localMedia: MediaModel, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        if enableServerReturnError {
            let error = SparkError.serviceFailed(code: -7000, reason: "create call error")
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(error)))
            return
        }
        
        if let oldModel = self.callModel,let caller = self.callerUser {
            self.callModel = FakeCallModelHelper.updateMediaCallModel(callModel: oldModel, updateUser: caller,localMedia:localMedia)
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(self.callModel!)))
        }
    }
    
}



