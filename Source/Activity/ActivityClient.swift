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

import UIKit
import ObjectMapper
import SparkSDKEncryptionKit
import Alamofire
import SwiftyJSON


public class ActivityClient {
    
    /// Callback when receive Message.
    ///
    /// - since: 1.4.0
    public var onMessageActivity:((MessageActivity) -> Void)?
    
    /// Callback when receive acknowledge activity.
    ///
    /// - since: 1.4.0
    public var onTypingActivity:((TypingActivity) -> Void)?
    
    /// Callback when delete Message.
    ///
    /// - since: 1.4.0
    public var onFlagActivity:((FlagActivity) -> Void)?
    
    
    let authenticator: Authenticator
    
    private func requestBuilder() -> ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator).path("activities")
    }
    
    private func statusRequestBuilder() ->ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator).path("status")
    }
    
    private func flagRequestBuilder() ->ServiceRequest.RainDropServerBuilder {
        return ServiceRequest.RainDropServerBuilder(authenticator).path("flags")
    }
    
    private func kmsRequestBuilder() -> ServiceRequest.KmsServerBuilder {
        return ServiceRequest.KmsServerBuilder(authenticator)
    }
    
    private func activityServiceBuilder() -> ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator)
    }
    
    /// Lists all messages in a room by room Id.
    /// If present, it includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter conversationId: The identifier of the conversation.
    /// - parameter sinceDate: the activities published date is after this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter midDate: The activities published date is before or after this date. At most limit/2 activities activities before and limit/2 activities after the date will be included, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter maxDate: the activities published date is before this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter limit:  Maximum number of activities return. Default is 6.
    /// - parameter personRefresh: (experimental)control if the person detail in activity need to be refreshed to latest. If person detail got      refreshed, person.id will be in UUID format even if original one is email. Default is false.
    /// - parameter lastActivityFirst: Sort order for the activities. Default is true.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func listMessageActivities(conversationId: String,
                                      sinceDate: String? = nil,
                                      maxDate: String? = nil,
                                      midDate: String? = nil,
                                      limit: Int? = nil,
                                      personRefresh: Bool? = false,
                                      lastActivityFirst: Bool? = false,
                                      queue: DispatchQueue? = nil,
                                      completionHandler: @escaping (ServiceResponse<[MessageActivity]>) -> Void)
    {
        let query = RequestParameter([
            "conversationId": conversationId,
            "sinceDate": sinceDate,
            "maxDate": maxDate,
            "maxDate": maxDate,
            "midDate": midDate,
            "limit": limit,
            "personRefresh": personRefresh,
            "lastActivityFirst": lastActivityFirst,
            ])
        
        let request = requestBuilder()
            .method(.get)
            .query(query)
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Detail of one messate activity.
    ///
    /// - parameter activityID: The identifier of the activity.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func messageActivityDetail(activityID: String,
                                      queue: DispatchQueue? = nil,
                                      completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        let request = requestBuilder()
            .method(.get)
            .path(activityID)
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Posts a plain text message, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the message is to be posted.
    /// - parameter content: The plain text message to be posted to the room.
    /// - parameter medtions: The mention items to be posted to the room.
    /// - parameter files: local file pathes to be uploaded to the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func postMessage(conversationID: String,
                            content: String?=nil,
                            mentions: [ActivityMentionModel]? = nil,
                            files: [URL]? = nil,
                            queue: DispatchQueue? = nil,
                            completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        
        let messageActivity = MessageActivity()
        messageActivity.conversationId = conversationID
        messageActivity.plainText = content
        
        if let fileList = files {
            messageActivity.action = MessageAction.share
            messageActivity.localFileList = fileList
        }else{
            messageActivity.action = MessageAction.post
        }
        
        if let mentionItems = mentions {
            messageActivity.mentionItems = mentionItems
        }
        
        if let roomResource = self.roomResources.filter({$0.conversationID == conversationID}).first,
            let encryptionUrl = roomResource.encryptionUrl,
            let keyMetarial = roomResource.keyMaterial,
            let spaceUrl = roomResource.spaceUrl
        {
            messageActivity.encryptionKeyUrl = encryptionUrl
            let msgPostOperation = ActivityPostOperation(authenticator:self.authenticator,
                                                         messageActivity: messageActivity,
                                                         keyMaterial:  keyMetarial,
                                                         spaceUrl: spaceUrl,
                                                         queue:queue,
                                                         completionHandler: completionHandler)
            SDKLogger.shared.info("Activity Added POSTing Queue...")
            self.postingOperationQueue.addOperation(msgPostOperation)
        }else{
            if self.roomResources.filter({$0.conversationID == conversationID}).first == nil{
                let roomModel = ActivityRoomResource(conversationId: conversationID)
                self.roomResources.append(roomModel)
            }
            let msgPostOperation = ActivityPostOperation(authenticator:self.authenticator,
                                                         messageActivity: messageActivity ,
                                                         queue:queue,
                                                         completionHandler: completionHandler)
            SDKLogger.shared.info("Activity Added PENDing Queue...")
            self.pendingOperationQueue.append(msgPostOperation)
            self.postNewMessageActivity(messageActivity: messageActivity)
        }
    }
    
    /// Deletes a message, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the message is to be posted.
    /// - parameter activityId: The messageId to be deleted in the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func deleteMessage(conversationID: String,
                              messageActivityId: String,
                              queue: DispatchQueue? = nil,
                              completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        
        let messageActivity = MessageActivity()
        messageActivity.conversationId = conversationID
        messageActivity.activityId = messageActivityId
        messageActivity.action = MessageAction.delete
        let msgPostOperation = ActivityPostOperation(authenticator:self.authenticator, messageActivity: messageActivity,queue:queue, completionHandler: completionHandler)
        self.postingOperationQueue.addOperation(msgPostOperation)
    }
    
    /// Post a message read indicator, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the indicator is to be posted.
    /// - parameter activityId: The activity that is read .
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func read(conversationID: String,
                     massageActivityId: String,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        let messageActivity = MessageActivity()
        messageActivity.conversationId = conversationID
        messageActivity.activityId = massageActivityId
        messageActivity.action = MessageAction.acknowledge
        let msgPostOperation = ActivityPostOperation(authenticator:self.authenticator, messageActivity: messageActivity,queue:queue, completionHandler: completionHandler)
        self.postingOperationQueue.addOperation(msgPostOperation)
    }
    
    /// Post a typing indicator, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the indicator is to be posted.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func startTyping(conversationID: String,
                            queue: DispatchQueue? = nil,
                            completionHandler: @escaping (ServiceResponse<Any>) -> Void) -> Void
    {
        let body = RequestParameter([
            "eventType": "status.start_typing",
            "conversationId" : conversationID
            ])
        let request = statusRequestBuilder().path("typing")
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseJSON(completionHandler)
    }
    
    /// Post a stop-typing indicator, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the indicator is to be posted.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func stopTyping(conversationID: String,
                           queue: DispatchQueue? = nil,
                           completionHandler: @escaping (ServiceResponse<Any>) -> Void) -> Void
    {
        let body = RequestParameter([
            "eventType": "status.stop_typing",
            "conversationId" : conversationID
            ])
        let request = statusRequestBuilder().path("typing")
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseJSON(completionHandler)
    }
    
    /// Post flag an activity action, to a activity by activity url.
    ///
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func flag(flagItemUrl: String,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<FlagActivity>) -> Void) -> Void
    {
        let body = RequestParameter([
            "flag-item": flagItemUrl,
            "state": "flagged"
            ])
        
        let request = flagRequestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Post  unflag an activity action, to a flag tem by flagId.
    ///
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func unFlag(flagItemId: String,
                       queue: DispatchQueue? = nil,
                       completionHandler: @escaping (ServiceResponse<Any>) -> Void) -> Void
    {
        let request = flagRequestBuilder().path(flagItemId)
            .method(.delete)
            .queue(queue)
            .build()
        request.responseJSON(completionHandler)
    }
    
    
    // MARK: Encryption Feature Variables
    private let kmsMessageServerUri = ServiceRequest.KMS_SERVER_ADDRESS + "/kms/messages"
    private var kmsCluster: String?
    private var rsaPublicKey: String?
    private var ephemeralKeyRequest: KmsEphemeralKeyRequest?
    private var ephemeralKeyFetched: Bool = false
    private var ephemeralKeyStr: String = ""
    private var receivedActivityPendingQueue : [MessageActivity] = [MessageActivity]()
    private var kmsRequestQueue : [KmsRequest] = [KmsRequest]()
    private var roomResources : [ActivityRoomResource] = [ActivityRoomResource]()
    private var postCompeletionHandler : ((ServiceResponse<MessageActivity>) -> Void)?
    private var postingOperationQueue: OperationQueue = OperationQueue()
    private var pendingOperationQueue: [ActivityPostOperation] = [ActivityPostOperation]()
    
    
    var userId :String = ""
    var deviceUrl : URL
    var uuid: String = ""
    var accessTokenStr = ""
    
    init(authenticator: Authenticator, diviceUrl: URL) {
        self.authenticator = authenticator
        self.deviceUrl = diviceUrl
        self.uuid = UUID().uuidString
        self.postingOperationQueue.maxConcurrentOperationCount = 1
    }
    
    // MARK: Encryption Feature Functions
    public func receiveNewMessageActivity( messageActivity: MessageActivity){
        self.receivedActivityPendingQueue.append(messageActivity)
        if self.roomResources.filter({$0.conversationID == messageActivity.conversationId}).first == nil{
            let roomModel = ActivityRoomResource(conversationId: messageActivity.conversationId!)
            roomModel.encryptionUrl = messageActivity.encryptionKeyUrl
            self.roomResources.append(roomModel)
        }
        if(self.userId == ""){
            self.requestUserId()
        }else if(self.kmsCluster == nil){
            self.requestClusterInfo()
        }else if(!self.ephemeralKeyFetched){
            self.requestEphemeralKey()
        }else{
            if let _ = self.roomResources.filter({$0.encryptionUrl == messageActivity.encryptionKeyUrl!}).first?.keyMaterial {
                self.processReadyMessageActivity(messageActivity)
            }else{
                self.requestKeyMaterial(messageActivity.encryptionKeyUrl!)
            }
        }
    }
    
    public func postNewMessageActivity(messageActivity: MessageActivity){
        if(self.userId == ""){
            self.requestUserId()
        }else if(self.kmsCluster == nil){
            self.requestClusterInfo()
        }else if(!self.ephemeralKeyFetched){
            self.requestEphemeralKey()
        }else{
            if let roomResource = self.roomResources.filter({$0.conversationID == messageActivity.conversationId!}).first{
                guard let encryptionUrl = roomResource.encryptionUrl
                    else{
                        self.requestConversationDetail(convasationId: roomResource.conversationID)
                        return
                }
                guard let _ = roomResource.keyMaterial
                    else{
                        self.requestKeyMaterial(encryptionUrl)
                        return
                }
                if let _ = messageActivity.localFileList{
                    guard let _ = roomResource.spaceUrl
                        else{
                            self.requestSpaceUrl(convasationId: roomResource.conversationID)
                            return
                    }
                }else{
                    self.processReadyMessageActivity(messageActivity)
                }
            }
        }
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
                    if let room = self.roomResources.filter({$0.encryptionUrl == keyUri}).first{
                        room.keyMaterial = keyMaterial
                        self.processPendingMessageActivities(keyUri)
                    }
                    _ = self.kmsRequestQueue.removeObject(equality: { $0.uri == keyUri})
                }
            }catch let error as NSError {
                SDKLogger.shared.debug("Error - Receive KmsMessage: \(error.debugDescription)")
            }
        }else{
            /// receive ephemaral key message
            do{
                let responseStr = kmsMessageModel.kmsMessageStrs?.first!
                let kmsresponse = try KmsEphemeralKeyResponse(responseMessage: responseStr, request: self.ephemeralKeyRequest!)
                self.ephemeralKeyStr = kmsresponse.jwkEphemeralKey
                self.ephemeralKeyFetched = true
                self.ephemeralKeyRequest = nil
                for receivedActivity in self.receivedActivityPendingQueue{
                    self.requestKeyMaterial(receivedActivity.encryptionKeyUrl!)
                }
                if let postingMessage = self.pendingOperationQueue.first?.messageActivity{
                    self.requestConversationDetail(convasationId: postingMessage.conversationId!)
                }
                
            }catch let error as NSError {
                SDKLogger.shared.debug("Error - Receive EpheMeralKMS: \(error.debugDescription)")
            }
        }
    }
    
    private func processReadyMessageActivity(_ messageActivity: MessageActivity){
        guard let acitivityKeyMaterial = self.roomResources.filter({$0.encryptionUrl == messageActivity.encryptionKeyUrl!}).first?.keyMaterial else{
            return
        }
        _ = self.receivedActivityPendingQueue.removeObject(equality: { $0.activityId == messageActivity.activityId })
        do {
            guard let chiperText = messageActivity.plainText
                else{
                    return;
            }
            if(chiperText != ""){
                let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
                let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
                messageActivity.plainText = clearText! as String
                messageActivity.markDownString()
            }
            if let files = messageActivity.files{
                var newFiles = [FileObjectModel]()
                for file in files{
                    if let displayname = file.displayName,
                        let src = file.scr
                    {
                        let nameData = try CjoseWrapper.content(fromCiphertext: displayname, key: acitivityKeyMaterial)
                        let clearName = NSString(data:nameData ,encoding: String.Encoding.utf8.rawValue)! as String
                        let srcData = try CjoseWrapper.content(fromCiphertext: src, key: acitivityKeyMaterial)
                        let clearSrc = NSString(data:srcData ,encoding: String.Encoding.utf8.rawValue)! as String
                        let newFile = FileObjectModel(displayName: clearName , mimeType: file.mimeType, objectType: file.objectType, image: file.image, fileSize: file.fileSize, scr: clearSrc, url: file.url)
                        newFiles.append(newFile)
                    }
                }
                messageActivity.files = newFiles
            }
            self.onMessageActivity?(messageActivity)
        }catch let error as NSError {
            SDKLogger.shared.debug("Process Activity Error - \(error.description)")
        }
    }
    
    /// Process received | posting pending activities
    private func processPendingMessageActivities( _ encryptionUrl: String){
        let receivePendingActivityArray = self.receivedActivityPendingQueue.filter({$0.encryptionKeyUrl == encryptionUrl})
        for activity in receivePendingActivityArray{
            self.processReadyMessageActivity(activity)
        }
        self.processFilePostingMessageActivities(encryptionUrl)
    }
    /// Process posting pending activities
    private func processFilePostingMessageActivities(_ encryptionUrl: String){
        if let roomResource = self.roomResources.filter({$0.encryptionUrl == encryptionUrl}).first,
            let keyMaterial = roomResource.keyMaterial
        {
            let postPendingActivityArray = self.pendingOperationQueue.filter({$0.encryptionUrl == encryptionUrl})
            for pendingOperation in postPendingActivityArray{
                pendingOperation.keyMaterial = keyMaterial
                if(pendingOperation.files == nil || roomResource.spaceUrl != nil){
                    pendingOperation.spaceUrl = roomResource.spaceUrl
                    self.postingOperationQueue.addOperation(pendingOperation)
                    self.pendingOperationQueue.removeObject(pendingOperation)
                }else{
                    self.requestSpaceUrl(convasationId: pendingOperation.messageActivity.conversationId!)
                }
            }
        }
    }
    
    private func requestEphemeralKey(){
        if(self.ephemeralKeyRequest != nil || self.ephemeralKeyFetched){
            return
        }
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
            
            self.requestEphemeralKey(ephemeralKeyRequest: self.ephemeralKeyRequest)
        }catch let error as NSError{
            SDKLogger.shared.debug("Error - RequestEphemeralKey \(error.description)")
        }
    }
    
    private func requestEphemeralKey(ephemeralKeyRequest: KmsEphemeralKeyRequest?){
        guard let message = ephemeralKeyRequest?.message,
            let clusterUri = ephemeralKeyRequest?.uri
            else {
                return
        }
        
        let parameters : [String: String] = ["kmsMessages" : message, "destination" : clusterUri]
        let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                          "Authorization" : "Bearer " + self.accessTokenStr]
        
        let url = URL(string: kmsMessageServerUri)
        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString(completionHandler: { (response) in
            switch response.result{
            case .success(_):
                break
            case .failure(_):
                break
            }
            SDKLogger.shared.debug("\(response) - RequestEphemeralKey")
        })
    }
    
    private func requestKeyMaterial(_ encryptionUrl: String){
        if let _ = self.kmsRequestQueue.filter({$0.uri == encryptionUrl}).first{
            return
        }else{
            do{
                let kmsRequest = try KmsRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: self.userId, bearer: self.accessTokenStr, method: "retrieve", uri: encryptionUrl)
                self.kmsRequestQueue.append(kmsRequest)
                self.requestKeyMaterial(kmsRequest: kmsRequest)
            }catch let error as NSError{
                SDKLogger.shared.debug("Error - CreateKMSReuqes: \(error.description)")
            }
        }
    }
    
    private func requestKeyMaterial(kmsRequest: KmsRequest){
        do{
            let serrizeData = kmsRequest.serialize()
            let chiperText = try CjoseWrapper.ciphertext(fromContent: serrizeData?.data(using: .utf8), key: self.ephemeralKeyStr)
            let kmsMessages = [chiperText]
            let parameters = ["kmsMessages" : kmsMessages, "destination" : "unused" ] as [String : Any]
            let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                              "Authorization" : "Bearer " + self.accessTokenStr]
            let url = URL(string: kmsMessageServerUri)
            Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString(completionHandler: { (response) in
                switch response.result{
                case .success:
                    break
                case .failure(let error):
                    SDKLogger.shared.debug("Error - requestKeyMaterial: \(error.localizedDescription)")
                }
            })
        }catch let error as NSError{
            SDKLogger.shared.debug("Error - requestKeyMaterial: \(error.localizedDescription)")
        }
    }
    
    
    private func requestConversationDetail(convasationId: String){
        
        let path = "conversations/" + convasationId
        let query = RequestParameter(["includeActivities": false,
                                      "includeParticipants": false
            ])
        let header : [String: String]  = [ "Authorization" : "Bearer " + self.accessTokenStr]
        let request = activityServiceBuilder().path(path)
            .query(query)
            .headers(header)
            .method(.get)
            .build()
        request.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: Any]
                    else{
                        return
                }
                if(responseDict["encryptionKeyUrl"] != nil) {
                    let encryptionUrl = responseDict["encryptionKeyUrl"]
                    if let room = self.roomResources.filter({$0.conversationID == convasationId}).first{
                        room.encryptionUrl = encryptionUrl as? String
                    }
                    let postPendingOperations = self.pendingOperationQueue.filter({$0.messageActivity.conversationId == convasationId})
                    for pendingOperation in postPendingOperations{
                        pendingOperation.messageActivity.encryptionKeyUrl = encryptionUrl as? String
                        pendingOperation.encryptionUrl = encryptionUrl as? String
                    }
                    self.requestKeyMaterial(encryptionUrl as! String)
                }
                break
            case .failure:
                break
            }
        }
    }
    
    private func requestSpaceUrl(convasationId: String){
        let path = "conversations/" + convasationId + "/space"
        let header : [String: String]  = [ "Authorization" : "Bearer " + self.accessTokenStr]
        let request = activityServiceBuilder().path(path)
            .headers(header)
            .method(.put)
            .build()
        request.responseJSON{ (response: ServiceResponse<Any>) in
            print(response)
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: Any]
                    else{
                        return;
                }
                if let room = self.roomResources.filter({$0.conversationID == convasationId}).first{
                    room.spaceUrl = responseDict["spaceUrl"]! as? String
                    self.processFilePostingMessageActivities(room.encryptionUrl!)
                    return;
                }
                break
            case .failure:
                break
            }
        }
    }
    
    
    
    private func requestUserId(){
        let request = activityServiceBuilder().path("users")
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
                self.requestUserId()
                break
            }
        }
    }
    
    private func requestClusterInfo(){
        let request = kmsRequestBuilder().path("kms")
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
                self.requestClusterInfo()
                break
            }
        }
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

