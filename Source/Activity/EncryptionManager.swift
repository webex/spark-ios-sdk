//
//  KmsMessageManager.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/26.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit
import SparkSDKEncryptionKit
import Alamofire
import SwiftyJSON

class EncryptionManager: NSObject {
    
    private let successStr:String = "SUCCESS:"
    private let kmsMessageServerUri = ServiceRequest.KMS_SERVER_ADDRESS + "/kms/messages"
    private var activityClient: ActivityClient?
    private var kmsCluster: String?
    private var rsaPublicKey: String?
    private var ephemeralKeyRequest: KmsEphemeralKeyRequest?
    private var ephemeralKeyFetched: Bool = false
    private var ephemeralKeyStr: String = ""
    private var pendingActivityQueue : [MessageActivity] = [MessageActivity]()
    private var kmsRequestQueue : [KmsRequest] = [KmsRequest]()
    private var keyMaterialDict : [String : String] = [String : String]()
    
    let authenticator: Authenticator
    var userId :String = ""
    var deviceUrl : URL
    var uuid: String = ""
    var accessTokenStr = ""
    
    init(authenticator: Authenticator, diviceUrl: URL, activityClient: ActivityClient? = nil) {
        self.authenticator = authenticator
        self.deviceUrl = diviceUrl
        self.uuid = UUID().uuidString
        if let tempClient = activityClient{
            self.activityClient = tempClient
        }
    }
    
    public func receiNewMessageActivity( messageActivity: MessageActivity){
        self.pendingActivityQueue.append(messageActivity)
        if(self.userId == ""){
            self.requestUserId()
        }else if(self.kmsCluster == nil){
            self.requestClusterInfo()
        }else if(!self.ephemeralKeyFetched){
            self.requestEphemeralKey()
        }else{
            if((self.keyMaterialDict[messageActivity.encryptionKeyUrl!]) != nil){
                self.processMessageActivity(messageActivity)
                return;
            }else{
                self.requestKeyMaterial(messageActivity)
            }
        }
    }
    
    public func processMessageActivity(_ messageActivity: MessageActivity){
        _ = self.pendingActivityQueue.removeObject(equality: { $0.activityId == messageActivity.activityId })
        guard let acitivityKeyMaterial = self.keyMaterialDict[messageActivity.encryptionKeyUrl!] else{
            return
        }
        do {
            guard let chiperText = messageActivity.plainText
                else{
                    return;
            }
            
            let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
            let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
            messageActivity.plainText = clearText! as String
            if let activityClient = self.activityClient{
                activityClient.onMessageActivity?(messageActivity)
            }
        }catch let error as NSError {
            print(error)
        }
    }
    public func checkEphemerralKeyForConversation( convId: String) -> Bool{
        return false
    }
    
    public func receiveKmsMessage( _ kmsMessageModel: KmsMessageModel){
        if(self.ephemeralKeyRequest == nil && self.ephemeralKeyFetched){
            /// receive decryption key message
            do{
                let responseStr = kmsMessageModel.kmsMessageStrs?.first!
                let kmsMessageData = try CjoseWrapper.content(fromCiphertext: responseStr, key: self.ephemeralKeyStr)
                let kmsMessageJson = JSON(data: kmsMessageData)
                let keyDict = kmsMessageJson["key"].object
                guard let dict = keyDict as? [String:Any] else{
                    throw NSError(domain: "error", code: 0, userInfo: nil)
                }
                if let keyMaterial = JSON(dict["jwk"]!).rawString(),
                    let keyUri = JSON(dict["uri"]!).rawString(){
                    self.keyMaterialDict[keyUri] = keyMaterial
                }
            }catch let error as NSError {
                print("Error - KeyMaterial: \(error.debugDescription)")
            }
        }else{
            /// receive ephemaral key message
            do{
                let responseStr = kmsMessageModel.kmsMessageStrs?.first!
                let kmsresponse = try KmsEphemeralKeyResponse(responseMessage: responseStr, request: self.ephemeralKeyRequest!)
                self.ephemeralKeyStr = kmsresponse.jwkEphemeralKey
                self.ephemeralKeyFetched = true
                self.ephemeralKeyRequest = nil
                self.requestKeyMaterial(self.pendingActivityQueue.first!)
            }catch let error as NSError {
                print("Error - EpheMeralKMS: \(error.debugDescription)")
            }
        }
    }
    
    public func requestEphemeralKey(){
        self.authenticator.accessToken { (res) in
            self.accessTokenStr = res!
        }
        do{
            guard let clusterUri = self.kmsCluster
                else {
                    return
            }
            let kmsClusterUri = clusterUri + "/ecdhe"
            self.ephemeralKeyRequest = try KmsEphemeralKeyRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: self.userId, bearer: self.accessTokenStr , method: "create", uri: kmsClusterUri, kmsStaticKey: self.rsaPublicKey!)
            
            guard let message = self.ephemeralKeyRequest?.message
                else {
                    return
            }
            
            let parameters : [String: String] = ["kmsMessages" : message, "destination" : clusterUri]
            let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                              "Authorization" : "Bearer " + self.accessTokenStr]
            
            let url = URL(string: kmsMessageServerUri)
            Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString(completionHandler: { (response) in
                print("\(response) - RequestEphemeralKey")
            })
        }catch let error as NSError{
            print("Error - RequestEphemeralKey \(error.description)")
        }
    }
    
    
    public func requestKeyMaterial(_ messageActivity: MessageActivity){
        do{
            let kmsRequest = try KmsRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: self.userId, bearer: self.accessTokenStr, method: "retrieve", uri: messageActivity.encryptionKeyUrl)
            let serrizeData = kmsRequest.serialize()
            let chiperText = try CjoseWrapper.ciphertext(fromContent: serrizeData?.data(using: .utf8), key: self.ephemeralKeyStr)
            print(chiperText)
            let kmsMessages = [chiperText]
            
            let parameters = ["kmsMessages" : kmsMessages, "destination" : "unused" ] as [String : Any]
            let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                              "Authorization" : "Bearer " + self.accessTokenStr]
            let url = URL(string: kmsMessageServerUri)
            Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString(completionHandler: { (response) in
                switch response.result{
                case .success:
                    self.kmsRequestQueue.append(kmsRequest)
                    break
                case .failure(let error):
                    print("kmsMessagesUrl error : \(error.localizedDescription)")
                    break
                }
            })
        }catch let errror as NSError{
            print("kmsMessagesUrl error : \(errror.description)")
        }
    }
    
    
    public func requestUserId(){
        let request = userInoRequestBuilder().path("users")
            .method(.get)
            .build()
        request.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: Any]
                    else{
                        return;
                }
                self.userId = responseDict["id"]! as! String
                self.requestClusterInfo()
                break
            case .failure:
                break
            }
        }
    }
    
    public func requestClusterInfo(){
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
                self.requestEphemeralKey()
                break
            case .failure:
                break
            }
        }
    }
    
    public func kmsReqeustBuilder() -> ServiceRequest.KmsServerBuilder {
        return ServiceRequest.KmsServerBuilder(authenticator)
    }
    public func userInoRequestBuilder() -> ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator)
    }
}

extension Array {
    mutating func removeObject(equality: (Element) -> Bool) -> Element? {
        for (idx, element) in self.enumerated() {
            if equality(element) {
                return self.remove(at: idx);
            }
        }
        return nil
    }
}

