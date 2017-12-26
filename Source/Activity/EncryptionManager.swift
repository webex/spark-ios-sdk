//
//  KmsMessageManager.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/26.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit
import SparkSDKEncryptionKit

class EncryptionManager: NSObject {
    
    private var activityClient: ActivityClient
    private var kmsCluster: String?
    private var rsaPublicKey: String?
    private var ephemeralKeyRequest: KmsEphemeralKeyRequest?
    private var ephemeralKeyStr: String?
    
    let authenticator: Authenticator
    var uuid: String = ""
    var userId :String = ""
    var deviceUrl : URL
    var accessTokenStr = ""

    init(authenticator: Authenticator, diviceUrl: URL, activityClient: ActivityClient) {
        self.authenticator = authenticator
        self.deviceUrl = diviceUrl
        self.uuid = UUID().uuidString
        self.activityClient = activityClient
    }
    
    
    public func receiNewMessageActivity( messageActivity: MessageActivity){
        
    }
    
    public func receiveKmaMessage( kmsMessage: KmsMessageModel){
        do{
            let responseStr = kmsMessage.kmsMessageStrs?.first!
            let kmsresponse = try KmsEphemeralKeyResponse(responseMessage: responseStr, request: self.ephemeralKeyRequest!)
            print("=========KMSR RESPONSE KEY \(kmsresponse.jwkEphemeralKey)")
            self.ephemeralKeyStr = kmsresponse.jwkEphemeralKey
        }catch let error as NSError {
            print("=========Error: \(error.debugDescription)")
        }
    }
    
    
    public func getEphemeralKeyStrForActivity(activity: MessageActivity){
        self.authenticator.accessToken { (res) in
            self.accessTokenStr = res!
        }
        do{
            self.ephemeralKeyRequest = try KmsEphemeralKeyRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: self.userId, bearer: self.accessTokenStr , method: "create", uri: self.kmsCluster!, kmsStaticKey: self.rsaPublicKey!)
            guard let encryptionUrl =  activity.encryptionKeyUrl
                else{
                    return;
            }
            let parameters : [String: String] = ["kmsMessages" : self.ephemeralKeyRequest!.message!, "destination" : encryptionUrl]
            let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                              "Authorization" : "Bearer " + self.accessTokenStr]
            let request = kmsReqeustBuilder().path("kms/messages")
                .method(.get)
                .headers(header)
                .body(RequestParameter(parameters))
                .build()
            request.responseJSON{ (response: ServiceResponse<Any>) in
                switch response.result {
                case .success:
                    print("Success - GetEphemeralKeyStrForActivity")
                    break
                case .failure:
                    print("Fail - GetEphemeralKeyStrForActivity")
                    break
                }
            }
        }catch let error as NSError{
            print("Error - GetEphemeralKeyStrForActivity \(error.description)")
        }
    }

    public func checkEphemerralKeyForConversation( convId: String) -> Bool{
        return false
    }

    public func receiveKmsMessage( message: KmsMessageModel){

        
        
//        do{
//            let kmsMessageData = try CjoseWrapper.content(fromCiphertext: str, key: self.jwkStr)
//            let kmsMessageJson = JSON(data: kmsMessageData)
//            let keyDict = kmsMessageJson["key"].object
//
//            guard let dict = keyDict as? [String:Any] else{
//                throw NSError(domain: "error", code: 0, userInfo: nil)
//            }
//            let keyStr = JSON(dict["jwk"]!).rawString()
//            do {
//                let plainTextData = try CjoseWrapper.content(fromCiphertext: self.postActivity!.plainText!, key: keyStr! )
//                let palinText1 = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
//                print("DecrypTMessage================>\(palinText1!)")
//                let text = "Hallo every one !!!!!"
//                let chiperText = try CjoseWrapper.ciphertext(fromContent: text.data(using: .utf8), key:keyStr!)
//                print("ChiperText ===============>>>>>\(chiperText)")
//
//            }catch let error as NSError {
//                print(error)
//            }
//        }catch let error as NSError {
//            print("Error while decrptKey, error: \(error.debugDescription)")
//        }
    }

    private func requestUserId(){
        let request = kmsReqeustBuilder().path("kms")
            .method(.get)
            .build()
        request.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: String]
                    else{
                        return;
                }
                self.kmsCluster = responseDict["kmsCluster"]
                self.rsaPublicKey = responseDict["rsaPublicKey"]
                break
            case .failure:
                break
            }
        }
    }
    
    private func requestClusterInfo(){
        let request = userInoRequestBuilder().path("users")
            .method(.get)
            .build()
        request.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: String]
                    else{
                        return;
                }
                self.userId = responseDict["id"]!
                break
            case .failure:
                break
            }
        }
    }
    
    private func ephemaralKeyRequst(){
        let request = kmsReqeustBuilder().path("kms/messages")
            .method(.get)
            .build()
        request.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: String]
                    else{
                        return;
                }
                self.kmsCluster = responseDict["kmsCluster"]
                self.rsaPublicKey = responseDict["rsaPublicKey"]
                break
            case .failure:
                break
            }
        }
    }
    
    private func kmsReqeustBuilder() -> ServiceRequest.KmsServerBuilder {
        return ServiceRequest.KmsServerBuilder(authenticator)
    }
    private func userInoRequestBuilder() -> ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator)
    }
    
    
}
