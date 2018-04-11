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
import Alamofire
import SwiftyJSON


public class MessageClient {
    
    /// Callback when receive Message.
    ///
    /// - since: 1.4.0
    public var onMessage:((MessageModel) -> Void)?
    
    let authenticator: Authenticator
    
    /// Lists all messages in a room by room's Id.
    /// If present, it includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter sinceDate: the messages published date is after this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter midDate: The messages published date is before or after this date. At most limit/2 messages before and limit/2 messages after the date will be included, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter maxDate: the messages published date is before this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter limit:  Maximum number of messages return. Default is 6.
    /// - parameter personRefresh: (experimental)control if the person detail in message need to be refreshed to latest. If person detail got      refreshed, person.id will be in UUID format even if original one is email. Default is false.
    /// - parameter lastMessageFirst: Sort order for the messages. Default is true.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func list(roomId: String,
                     sinceDate: String? = nil,
                     maxDate: String? = nil,
                     midDate: String? = nil,
                     limit: Int? = nil,
                     personRefresh: Bool? = false,
                     lastMessageFirst: Bool? = true,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<[MessageModel]>) -> Void)
    {
        let query = RequestParameter([
            "conversationId": roomId.sparkSplitString(),
            "sinceDate": sinceDate,
            "maxDate": maxDate,
            "midDate": midDate,
            "limit": limit,
            "personRefresh": personRefresh,
            "lastActivityFirst": lastMessageFirst,
            ])
        
        let request = messageServiceBuilder().path("activities")
            .keyPath("items")
            .method(.get)
            .query(query)
            .queue(queue)
            .build()
       
        if self.encryptKeyReadyFor(roomId){
            let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first
            let listOperation = ListMessageOperation(roomId: roomId,
                                                     listRequest: request,
                                                     keyMaterial: roomResource?.keyMaterial,
                                                     completionHandler: completionHandler)
            self.executeOperationQueue.addOperation(listOperation)
            return
        }else{
            if (self.roomResourceList.filter({$0.roomId == roomId}).first == nil){
                let roomSource = RoomResourceModel(roomId: roomId)
                self.roomResourceList.append(roomSource)
            }
            let listOperation = ListMessageOperation(roomId: roomId,
                                                     listRequest: request,
                                                     completionHandler: completionHandler)
            self.pendingListOperationList.append(listOperation)
            if(!self.isClientReady){
                self.requestClientInfo()
            }else{
                self.requestEncryptionUrlFor(roomId)
            }
        }
    }
    
    /// Detail of one message.
    ///
    /// - parameter messageID: The identifier of the message.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func get(messageID: String,
                    queue: DispatchQueue? = nil,
                    completionHandler: @escaping (ServiceResponse<MessageModel>) -> Void)
    {
        let request = messageServiceBuilder().path("activities")
            .method(.get)
            .path(messageID.sparkSplitString())
            .queue(queue)
            .build()
        request.responseObject { (response : ServiceResponse<MessageModel>) in
            switch response.result{
            case .success(let message):
                if self.encryptKeyReadyFor(message.roomId!){
                    self.decryptMessage(message)
                    completionHandler(response)
                }else{
                    self.pendingDetailMessageList[message.id!] = completionHandler
                    self.receiveNewMessage(message: message)
                }
                break
            case .failure(_):
                completionHandler(response)
                break
            }
        }
    }
    
    /// Posts a plain text message to a room by user email
    ///
    /// - parameter email: The email of the user where the message is to be posted.
    /// - parameter content: The plain text message to be posted to the room.
    /// - parameter medtions: The mention items to be posted to the room.
    /// - parameter files: local file pathes to be uploaded to the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func post(email: String,
                     text: String?=nil,
                     mentions: [MessageMentionModel]? = nil,
                     files: [FileObjectModel]? = nil,
                     queue: DispatchQueue? = nil,
                     uploadProgressHandler: ((FileObjectModel, Double)->Void)? = nil,
                     completionHandler: @escaping (ServiceResponse<MessageModel>) -> Void)
    {
        if let roomResource = self.roomResourceList.filter({$0.email == email}).first{
            self.post(roomId: roomResource.roomId, text: text, mentions: mentions, files: files, queue: queue, uploadProgressHandler: uploadProgressHandler, completionHandler: completionHandler)
        }else{
            let query = RequestParameter([
                "activitiesLimit": 0,
                "compact": true
                ])
            let path = "conversations/user/"+email
            let request = messageServiceBuilder().path(path)
                .method(.put)
                .query(query)
                .queue(queue)
                .build()
            request.responseObject{ (response: ServiceResponse<Room>) in
                switch response.result{
                case .success(let targetRoom):
                    let roomId = String.sparkEncodedRoomId(targetRoom.id)
                    if let roomResource = self.roomResourceList.filter({$0.email == email}).first{
                        roomResource.roomId = roomId!
                    }else{
                        let roomSource = RoomResourceModel(email: email)
                        roomSource.roomId = roomId!
                        self.roomResourceList.append(roomSource)
                    }
                    self.post(roomId: roomId!, text: text, mentions: mentions, files: files, queue: queue, uploadProgressHandler: uploadProgressHandler, completionHandler: completionHandler)
                    break
                case .failure(let err):
                    let result = Result<MessageModel>.failure(err)
                    completionHandler(ServiceResponse(nil, result))
                    break
                }
            }
        }
    }
    
    /// Posts a plain text message, to a room by roomId.
    ///
    /// - parameter roomId: The identifier of the room where the message is to be posted.
    /// - parameter content: The plain text message to be posted to the room.
    /// - parameter medtions: The mention items to be posted to the room.
    /// - parameter files: local file pathes to be uploaded to the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func post(roomId: String,
                     text: String?=nil,
                     mentions: [MessageMentionModel]? = nil,
                     files: [FileObjectModel]? = nil,
                     queue: DispatchQueue? = nil,
                     uploadProgressHandler: ((FileObjectModel, Double)->Void)? = nil,
                     completionHandler: @escaping (ServiceResponse<MessageModel>) -> Void)
    {
        let message = MessageModel()
        message.roomId = roomId
        message.text = text
        
        if let mentionItems = mentions {
            message.mentionedPeople = [String]()
            message.mentionedGroup = [String]()
            for mentionItem in mentionItems{
                if mentionItem.mentionType == .person{
                    message.mentionedPeople?.append(mentionItem.personId!)
                }
                if mentionItem.mentionType == .group{
                    message.mentionedGroup?.append(mentionItem.groupType!.rawValue)
                }
            }
        }
        
        if let fileList = files {
            message.messageAction = MessageAction.share
            message.files = fileList
            if self.readyToShareFor(roomId){
                let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first
                message.encryptionKeyUrl = roomResource?.encryptionUrl
                let msgPostOperation = PostMessageOperation(authenticator:self.authenticator,
                                                            message: message,
                                                            keyMaterial:  roomResource?.keyMaterial,
                                                            spaceUrl: roomResource?.spaceUrl,
                                                            queue:queue,
                                                            uploadingProgressHandler : uploadProgressHandler,
                                                            completionHandler: completionHandler)
                self.executeOperationQueue.addOperation(msgPostOperation)
                return
            }else if self.encryptKeyReadyFor(roomId){
                let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first
                message.encryptionKeyUrl = roomResource?.encryptionUrl
                let msgPostOperation = PostMessageOperation(authenticator:self.authenticator,
                                                            message: message,
                                                            keyMaterial:  roomResource?.keyMaterial,
                                                            queue:queue,
                                                            uploadingProgressHandler : uploadProgressHandler,
                                                            completionHandler: completionHandler)
                self.pendingOperationList.append(msgPostOperation)
                self.requestSpaceUrl(roomId: roomId)
                return
            }
        }else{
            message.messageAction = MessageAction.post
            if self.encryptKeyReadyFor(roomId){
                let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first
                message.encryptionKeyUrl = roomResource?.encryptionUrl
                let msgPostOperation = PostMessageOperation(authenticator:self.authenticator,
                                                            message: message,
                                                            keyMaterial:roomResource?.keyMaterial,
                                                            queue:queue,
                                                            completionHandler: completionHandler)
                self.executeOperationQueue.addOperation(msgPostOperation)
                return
            }
        }
        
        if (self.roomResourceList.filter({$0.roomId == roomId}).first == nil){
            let roomSource = RoomResourceModel(roomId: roomId)
            self.roomResourceList.append(roomSource)
        }
        let msgPostOperation = PostMessageOperation(authenticator:self.authenticator,
                                                    message: message,
                                                    queue:queue,
                                                    uploadingProgressHandler : uploadProgressHandler,
                                                    completionHandler: completionHandler)
        self.pendingOperationList.append(msgPostOperation)
        if(!self.isClientReady){
            self.requestClientInfo()
        }else{
            self.requestEncryptionUrlFor(roomId)
        }
    }
    
    /// Deletes a message, to a room by roomId.
    ///
    /// - parameter roomId: The identifier of the room where the message is to be posted.
    /// - parameter messageId: The messageId to be deleted in the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func delete(roomId: String,
                       messageId: String,
                       queue: DispatchQueue? = nil,
                       completionHandler: @escaping (ServiceResponse<MessageModel>) -> Void)
    {
        
        let message = MessageModel()
        message.roomId = roomId
        message.id = messageId
        message.messageAction = MessageAction.delete
        let msgPostOperation = PostMessageOperation(authenticator:self.authenticator, message: message,queue:queue, completionHandler: completionHandler)
        self.executeOperationQueue.addOperation(msgPostOperation)
    }
    
    /// Download a file object, download both file body / thumbnail if exist.
    ///
    /// - parameter roomId: The identifier of the room where the fike is fetched.
    /// - parameter file: file object.
    /// - parameter downLoadProgressHandler: the download progress indicator.
    /// - parameter completionHandler: downloaded file local address wiil be stored in "file.localFileUrl"
    /// - returns: Void
    /// - since: 1.4.0
    public func downLoadFile(roomId: String,
                             file: FileObjectModel,
                             downLoadProgressHandler: ((Double)->Void)? = nil,
                             completionHandler: @escaping (FileObjectModel,FileDownLoadState) -> Void){
        
        let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first
        let downLoadOperation = DownLoadFileOperation(token: accessTokenStr,
                                                      uuid: self.uuid,
                                                      fileModel: file,
                                                      keyMatiarial: (roomResource?.keyMaterial)!,
                                                      progressHandler: downLoadProgressHandler,
                                                      completionHandler:completionHandler)
        SDKLogger.shared.info("File Added Downloading Queue...")
        self.executeOperationQueue.addOperation(downLoadOperation)
    }
    
    /// Download a file object, download both file thumbnail only if exist.
    ///
    /// - parameter roomId: The identifier of the room where the fike is fetched.
    /// - parameter file: file object.
    /// - parameter downLoadProgressHandler: the download progress indicator.
    /// - parameter completionHandler: downloaded file local address wiil be stored in "file.localFileUrl"
    /// - returns: Void
    /// - since: 1.4.0
    public func downLoadThumbNail(roomId: String,
                                  file: FileObjectModel,
                                  downLoadProgressHandler: ((Double)->Void)? = nil,
                                  completionHandler: @escaping (FileObjectModel,FileDownLoadState) -> Void){
        
        let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first
        let downLoadOperation = DownLoadFileOperation(token: accessTokenStr,
                                                      uuid: self.uuid,
                                                      fileModel: file,
                                                      keyMatiarial: (roomResource?.keyMaterial)!,
                                                      downLoadType: .ThumbOnly,
                                                      progressHandler: downLoadProgressHandler,
                                                      completionHandler:completionHandler)
        SDKLogger.shared.info("File Added Downloading Queue...")
        self.executeOperationQueue.addOperation(downLoadOperation)
    }
    
    /// Download a file object, download both file body only if exist.
    ///
    /// - parameter roomId: The identifier of the room where the fike is fetched.
    /// - parameter file: file object.
    /// - parameter downLoadProgressHandler: the download progress indicator.
    /// - parameter completionHandler: downloaded file local address wiil be stored in "file.localFileUrl"
    /// - returns: Void
    /// - since: 1.4.0
    public func downLoadFileBody(roomId: String,
                                 file: FileObjectModel,
                                 downLoadProgressHandler: ((Double)->Void)? = nil,
                                 completionHandler: @escaping (FileObjectModel,FileDownLoadState) -> Void){
        
        let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first
        let downLoadOperation = DownLoadFileOperation(token: accessTokenStr,
                                                      uuid: self.uuid,
                                                      fileModel: file,
                                                      keyMatiarial: (roomResource?.keyMaterial)!,
                                                      downLoadType: .BodyOnly,
                                                      progressHandler: downLoadProgressHandler,
                                                      completionHandler:completionHandler)
        SDKLogger.shared.info("File Added Downloading Queue...")
        self.executeOperationQueue.addOperation(downLoadOperation)
    }
    
    // MARK: - Encryption Feature Variables
    /// MessageClient Errors
    enum MSGErrorString: String {
        case clientInfoFetchFail = "Client Info Fetch Fail"
        case ephemaralKeyFetchFail = "EphemaralKey Fetch Fail"
        case kmsInfoFetchFail = "KMS Info Fetch Fail"
        case keyMaterialFetchFail = "Key Info Fetch Fail"
        case encryptionUrlFetchFail = "Encryption Info Fetch Fail"
        case spaceUrlFetchFail = "Space Info Fetch Fail"
        case emptyTextError = "Expected Text Not Found"
    }
    private let kmsMessageServerUri = ServiceRequest.KMS_SERVER_ADDRESS + "/kms/messages"
    private var roomResourceList : [RoomResourceModel] = [RoomResourceModel]()
    private var kmsRequestList : [KmsRequest] = [KmsRequest]()
    private var noEncryptionConvasationList : [String] = [String]()
    private var receivedMessageList : [MessageModel] = [MessageModel]()
    private var pendingOperationList: [PostMessageOperation] = [PostMessageOperation]()
    private var pendingListOperationList: [ListMessageOperation] = [ListMessageOperation]()
    private var pendingDetailMessageList: [String: (ServiceResponse<MessageModel>) -> Void] = [String: (ServiceResponse<MessageModel>) -> Void]()
    private var executeOperationQueue: OperationQueue = OperationQueue()
  
    var deviceUrl : URL
    var uuid: String = ""
    var accessTokenStr = ""
    var userId : String?
    private var kmsCluster: String?
    private var rsaPublicKey: String?
    private var ephemeralKeyRequest: KmsEphemeralKeyRequest?
    private var ephemeralKeyFetched: Bool = false
    private var ephemeralKeyStr: String = ""
    
    init(authenticator: Authenticator, diviceUrl: URL) {
        self.authenticator = authenticator
        self.deviceUrl = diviceUrl
        self.uuid = UUID().uuidString
        self.executeOperationQueue.maxConcurrentOperationCount = 1
    }
    
    // MARK: - Encryption Feature Functions
    public func receiveNewMessage( message: MessageModel){
        if(message.encryptionKeyUrl != nil){
            self.receivedMessageList.append(message)
            if let room = self.roomResourceList.filter({$0.roomId == message.roomId}).first{
                if(room.encryptionUrl != message.encryptionKeyUrl){
                    room.encryptionUrl = message.encryptionKeyUrl
                    room.keyMaterial = nil
                }
            }else {
                let roomModel = RoomResourceModel(roomId: message.roomId!)
                roomModel.encryptionUrl = message.encryptionKeyUrl
                self.roomResourceList.append(roomModel)
            }
            if(!self.isClientReady){
                self.requestClientInfo()
            }else if(self.encryptKeyReadyFor(message.roomId!)){
                self.processReceivedMessage(message)
            }else{
                self.requestKeyMaterial(message.encryptionKeyUrl!)
            }
        }else{
            if let comHandler = self.pendingDetailMessageList[message.id!]{
                let result = Result<MessageModel>.success(message)
                comHandler(ServiceResponse.init(nil, result))
                self.pendingDetailMessageList.removeValue(forKey: message.id!)
            }else{
                self.onMessage?(message)
            }
        }
    }
    
    public func receiveKmsMessage( _ kmsMessageModel: KmsMessageModel){
        if(self.ephemeralKeyRequest == nil && self.ephemeralKeyFetched){
            /// receive key material
            do{
                let responseStr = kmsMessageModel.kmsMessageStrs?.first!
                let kmsMessageData = try CjoseWrapper.content(fromCiphertext: responseStr, key: self.ephemeralKeyStr)
                let kmsMessageJson = JSON(data: kmsMessageData)
                
                if let dict = kmsMessageJson["key"].object as? [String:Any]{
                    if let keyMaterial = JSON(dict["jwk"]!).rawString(),
                        let keyUri = JSON(dict["uri"]!).rawString(){
                        if let room = self.roomResourceList.filter({$0.encryptionUrl == keyUri}).first{
                            room.keyMaterial = keyMaterial
                            self.processPendingMessages(keyUri)
                        }
                        _ = self.kmsRequestList.removeObject(equality: { $0.uri == keyUri})
                    }
                }else if let roomId = self.noEncryptionConvasationList.popLast(),
                    let keys = kmsMessageJson["keys"].object as? [[String : Any]]{
                    for keyDict in keys{
                        let key : KmsKey = try KmsKey(from: keyDict)
                        let encriptionUrl = key.uri
                        let keyMaterial = key.jwk
                        if let room = self.roomResourceList.filter({$0.roomId == roomId}).first{
                            room.keyMaterial = keyMaterial
                            room.encryptionUrl = encriptionUrl
                            self.processFilePostingMessagesWith(roomId)
                        }
                    }
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
                for roomResouce in self.roomResourceList{
                    if let encrptionUrl = roomResouce.encryptionUrl{
                        if let _ = roomResouce.keyMaterial{
                            self.processPendingMessages(encrptionUrl)
                        }else{
                            self.requestKeyMaterial(encrptionUrl)
                        }
                    }else{
                        self.requestEncryptionUrlFor(roomResouce.roomId)
                    }
                }
            }catch let error as NSError {
                self.ephemeralKeyRequest = nil
                SDKLogger.shared.debug("Error - Receive EpheMeralKMS: \(error.debugDescription)")
            }
        }
    }
    
    private func processReceivedMessage(_ message: MessageModel){
        guard let acitivityKeyMaterial = self.roomResourceList.filter({$0.encryptionUrl == message.encryptionKeyUrl!}).first?.keyMaterial else{
            return
        }
        _ = self.receivedMessageList.removeObject(equality: { $0.id == message.id })
        do {
            if message.text == nil{
                message.text = ""
            }
            guard let chiperText = message.text
                else{
                    return;
            }
            if(chiperText != ""){
                let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
                let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
                message.text = clearText! as String
//                message.html = clearText! as String
            }
            if let files = message.files{
                for file in files{
                    if let displayname = file.displayName,
                        let scr = file.scr
                    {
                        let nameData = try CjoseWrapper.content(fromCiphertext: displayname, key: acitivityKeyMaterial)
                        let clearName = NSString(data:nameData ,encoding: String.Encoding.utf8.rawValue)! as String
                        let srcData = try CjoseWrapper.content(fromCiphertext: scr, key: acitivityKeyMaterial)
                        let clearSrc = NSString(data:srcData ,encoding: String.Encoding.utf8.rawValue)! as String
                        if let image = file.thumb{
                            let imageSrcData = try CjoseWrapper.content(fromCiphertext: image.scr, key: acitivityKeyMaterial)
                            let imageClearSrc = NSString(data:imageSrcData ,encoding: String.Encoding.utf8.rawValue)! as String
                            image.scr = imageClearSrc
                        }
                        file.displayName = clearName
                        file.scr = clearSrc
                    }
                }
                message.files = files
            }
            if let comHandler = self.pendingDetailMessageList[message.id!]{
                let result = Result<MessageModel>.success(message)
                comHandler(ServiceResponse.init(nil, result))
                self.pendingDetailMessageList.removeValue(forKey: message.id!)
            }else{
                if message.roomType == RoomType.direct{
                    if let userID = userId{
                        let personId = String.sparkEncodedUserId(userID)
                        message.toPersonId = personId
                    }
                }
                self.onMessage?(message)
            }
        }catch let error as NSError {
            SDKLogger.shared.debug("Process Message Error - \(error.description)")
        }
    }
    
    private func decryptMessage(_ message: MessageModel){
        guard let acitivityKeyMaterial = self.roomResourceList.filter({$0.roomId == message.roomId!}).first?.keyMaterial else{
            return
        }
        _ = self.receivedMessageList.removeObject(equality: { $0.id == message.id })
        do {
            if message.text == nil{
                message.text = ""
            }
            guard let chiperText = message.text
                else{
                    return;
            }
            if(chiperText != ""){
                let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
                let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
                message.text = clearText! as String
            }
            if let files = message.files{
                for file in files{
                    if let displayname = file.displayName,
                        let scr = file.scr
                    {
                        let nameData = try CjoseWrapper.content(fromCiphertext: displayname, key: acitivityKeyMaterial)
                        let clearName = NSString(data:nameData ,encoding: String.Encoding.utf8.rawValue)! as String
                        let srcData = try CjoseWrapper.content(fromCiphertext: scr, key: acitivityKeyMaterial)
                        let clearSrc = NSString(data:srcData ,encoding: String.Encoding.utf8.rawValue)! as String
                        if let image = file.thumb{
                            let imageSrcData = try CjoseWrapper.content(fromCiphertext: image.scr, key: acitivityKeyMaterial)
                            let imageClearSrc = NSString(data:imageSrcData ,encoding: String.Encoding.utf8.rawValue)! as String
                            image.scr = imageClearSrc
                        }
                        file.displayName = clearName
                        file.scr = clearSrc
                    }
                }
                message.files = files
            }
        }catch let error as NSError {
            SDKLogger.shared.debug("Process Message Error - \(error.description)")
        }
    }
    
    
    /// Process received | posting pending messges
    private func processPendingMessages( _ encryptionUrl: String){
        /// process received acitivities
        let receivePendingMessageArray = self.receivedMessageList.filter({$0.encryptionKeyUrl == encryptionUrl})
        for message in receivePendingMessageArray{
            self.processReceivedMessage(message)
        }
        /// process post pending messages
        self.processFilePostingMessages(encryptionUrl)
        
        /// process pending list requests if exist
        self.processPendingListRequest(encryptionUrl)
    }
    
    /// Process posting pending messages
    private func processFilePostingMessages(_ encryptionUrl: String){
        if let roomResource = self.roomResourceList.filter({$0.encryptionUrl == encryptionUrl}).first,
            let keyMaterial = roomResource.keyMaterial
        {
            let postPendingMessageArray = self.pendingOperationList.filter({$0.encryptionUrl == encryptionUrl})
            for pendingOperation in postPendingMessageArray{
                pendingOperation.keyMaterial = keyMaterial
                if(pendingOperation.message.messageAction == .post){
                    self.executeOperationQueue.addOperation(pendingOperation)
                    self.pendingOperationList.removeObject(pendingOperation)
                }else{
                    if let spaceUrl =  roomResource.spaceUrl{
                        pendingOperation.spaceUrl = spaceUrl
                        self.executeOperationQueue.addOperation(pendingOperation)
                        self.pendingOperationList.removeObject(pendingOperation)
                    }else{
                        self.requestSpaceUrl(roomId: pendingOperation.message.roomId!)
                    }
                }
            }
        }
    }
    
    private func processFilePostingMessagesWith( _ roomId: String){
        if let roomResource = self.roomResourceList.filter({$0.roomId == roomId}).first,
            let keyMaterial = roomResource.keyMaterial,
            let encryptionUrl = roomResource.encryptionUrl
        {
            let postPendingMessageArray = self.pendingOperationList.filter({$0.message.roomId == roomId})
            for pendingOperation in postPendingMessageArray{
                pendingOperation.keyMaterial = keyMaterial
                pendingOperation.encryptionUrl = encryptionUrl
                if(pendingOperation.message.messageAction == .post){
                    self.executeOperationQueue.addOperation(pendingOperation)
                    self.pendingOperationList.removeObject(pendingOperation)
                }else{
                    if let spaceUrl =  roomResource.spaceUrl{
                        pendingOperation.spaceUrl = spaceUrl
                        self.executeOperationQueue.addOperation(pendingOperation)
                        self.pendingOperationList.removeObject(pendingOperation)
                    }else{
                        self.requestSpaceUrl(roomId: pendingOperation.message.roomId!)
                    }
                }
            }
        }
    }
    /// Process List Acitivities Requests
    private func processPendingListRequest(_ encryptionUrl: String){
        if let roomResource = self.roomResourceList.filter({$0.encryptionUrl == encryptionUrl}).first,
            let keyMaterial = roomResource.keyMaterial
        {
            let roomId = roomResource.roomId
            let listMessageRqeustList = self.pendingListOperationList.filter({$0.roomId == roomId})
            for pendingOperation in listMessageRqeustList{
                pendingOperation.keyMaterial = keyMaterial
                self.executeOperationQueue.addOperation(pendingOperation)
                self.pendingListOperationList.removeObject(pendingOperation)
            }
        }
    }
    
    // MARK: - KeyMaterial/EncryptionUrl/SpaceUrl Info Request Part
    private func requestEncryptionUrlFor(_ roomId: String){
        
        let path = "conversations/" + roomId.sparkSplitString()
        let query = RequestParameter(["includeActivities": false,
                                      "includeParticipants": false
            ])
        let header : [String: String]  = [ "Authorization" : "Bearer " + self.accessTokenStr]
        let request = messageServiceBuilder().path(path)
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
                if(responseDict["encryptionKeyUrl"] != nil  || responseDict["defaultActivityEncryptionKeyUrl"] != nil) {
                    let encryptionUrl = responseDict["encryptionKeyUrl"] != nil ? responseDict["encryptionKeyUrl"] : responseDict["defaultActivityEncryptionKeyUrl"]
                    if let room = self.roomResourceList.filter({$0.roomId == roomId}).first{
                        if(room.encryptionUrl == nil){
                            room.encryptionUrl = encryptionUrl as? String
                        }else{
                            return
                        }
                    }
                    let postPendingOperations = self.pendingOperationList.filter({$0.message.roomId == roomId})
                    for pendingOperation in postPendingOperations{
                        pendingOperation.message.encryptionKeyUrl = encryptionUrl as? String
                        pendingOperation.encryptionUrl = encryptionUrl as? String
                    }
                    self.requestKeyMaterial(encryptionUrl as! String)
                }else{
                    do{
                        let kmsRequest = try KmsRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: self.userId, bearer: self.accessTokenStr, method: "create", uri: "/keys")
                        kmsRequest.additionalAttributes = ["count" : 1]
                        let serrizeData = kmsRequest.serialize()
                        let chiperText = try CjoseWrapper.ciphertext(fromContent: serrizeData?.data(using: .utf8), key: self.ephemeralKeyStr)
                        let kmsMessages = [chiperText]
                        let parameters = ["kmsMessages" : kmsMessages, "destination" : "unused" ] as [String : Any]
                        let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                                          "Authorization" : "Bearer " + self.accessTokenStr]
                        let url = URL(string: self.kmsMessageServerUri)
                        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString(completionHandler: { (response) in
                            SDKLogger.shared.debug("RequestKMS UnUsed Key Response ============  \(response)")
                            if self.noEncryptionConvasationList.filter({$0 == roomId}).first == nil{
                                self.noEncryptionConvasationList.append(roomId)
                            }
                        })
                    }catch let error as NSError{
                        SDKLogger.shared.debug("Error - CreateKMSReuqes: \(error.description)")
                    }
                }
                break
            case .failure:
                let error = SparkError.serviceFailed(code: -7000, reason: MSGErrorString.encryptionUrlFetchFail.rawValue)
                let tempError = Result<MessageModel>.failure(error)
                self.cancelPendingMessageOperationsFor(roomId, result: tempError)
                break
            }
        }
    }
    
    private func requestKeyMaterial(_ encryptionUrl: String){
        if let roomResouce = self.roomResourceList.filter({$0.encryptionUrl == encryptionUrl}).first,
            let _ = roomResouce.keyMaterial{
            return
        }else{
            do{
                let kmsRequest = try KmsRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: self.userId, bearer: self.accessTokenStr, method: "retrieve", uri: encryptionUrl)
                let serrizeData = kmsRequest.serialize()
                let chiperText = try CjoseWrapper.ciphertext(fromContent: serrizeData?.data(using: .utf8), key: self.ephemeralKeyStr)
                let kmsMessages = [chiperText]
                let parameters = ["kmsMessages" : kmsMessages, "destination" : "unused" ] as [String : Any]
                let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                                  "Authorization" : "Bearer " + self.accessTokenStr]
                let url = URL(string: kmsMessageServerUri)
                Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString(completionHandler: { (response) in
                    self.kmsRequestList.append(kmsRequest)
                    SDKLogger.shared.debug("RequestKMS Material Response ============  \(response)")
                })
            }catch let error as NSError{
                SDKLogger.shared.debug("Error - CreateKMSReuqes: \(error.description)")
            }
        }
    }
    
    private func requestSpaceUrl(roomId: String){
        let path = "conversations/" + roomId.sparkSplitString() + "/space"
        let header : [String: String]  = [ "Authorization" : "Bearer " + self.accessTokenStr]
        let request = messageServiceBuilder().path(path)
            .headers(header)
            .method(.put)
            .build()
        request.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: Any]
                    else{
                        return;
                }
                if let room = self.roomResourceList.filter({$0.roomId == roomId}).first{
                    room.spaceUrl = responseDict["spaceUrl"]! as? String
                    self.processFilePostingMessages(room.encryptionUrl!)
                    return;
                }
                break
            case .failure:
                let error = SparkError.serviceFailed(code: -7000, reason: MSGErrorString.spaceUrlFetchFail.rawValue)
                let tempError = Result<MessageModel>.failure(error)
                self.cancelPendingMessageOperationsFor(roomId, result: tempError)
                break
            }
        }
    }
    
    // MARK: - Client Info Request Part
    private func finishClientInfoRequest(success: Bool){
        if(success){
            if(self.kmsCluster != nil && self.userId != nil){
                self.requestEphemeralKey()
                if(self.ephemeralKeyRequest != nil){
                    let deadlineTime = DispatchTime.now() + .seconds(20)
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                        if(!self.ephemeralKeyFetched){
                            self.ephemeralKeyRequest = nil
                            let error = SparkError.serviceFailed(code: -7000, reason: MSGErrorString.ephemaralKeyFetchFail.rawValue)
                            let tempError = Result<MessageModel>.failure(error)
                            self.cancelAllPendingMessageOperations(result: tempError)
                        }
                    }
                }
            }
        }else{
            let error = SparkError.serviceFailed(code: -7000, reason: MSGErrorString.clientInfoFetchFail.rawValue)
            let tempError = Result<MessageModel>.failure(error)
            self.cancelAllPendingMessageOperations(result: tempError)
        }
    }
    
    private func requestClientInfo(){
        let userIdRequest = messageServiceBuilder().path("users")
            .method(.get)
            .build()
        userIdRequest.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: Any]
                    else{
                        return;
                }
                if let userid = responseDict["id"]{
                    self.userId = userid as? String
                }
                self.finishClientInfoRequest(success: true)
                break
            case .failure:
                self.finishClientInfoRequest(success: false)
                break
            }
        }
        
        let clusterRequest = kmsRequestBuilder().path("kms")
            .method(.get)
            .build()
        clusterRequest.responseJSON{ (response: ServiceResponse<Any>) in
            switch response.result {
            case .success(let value):
                guard let responseDict = value as? [String: String]
                    else{
                        return;
                }
                self.kmsCluster = responseDict["kmsCluster"]
                self.rsaPublicKey = responseDict["rsaPublicKey"]
                self.finishClientInfoRequest(success: true)
                break
            case .failure:
                self.finishClientInfoRequest(success: false)
                break
            }
        }
    }
    
    private func requestEphemeralKey(){
        if(self.ephemeralKeyRequest != nil || self.ephemeralKeyFetched){
            return
        }
        self.authenticator.accessToken { (res) in
            self.accessTokenStr = res!
            do{
                guard let clusterUri = self.kmsCluster
                    else {
                        return
                }
                let kmsClusterUri = clusterUri + "/ecdhe"
                self.ephemeralKeyRequest = try KmsEphemeralKeyRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: self.userId, bearer: self.accessTokenStr , method: "create", uri: kmsClusterUri, kmsStaticKey: self.rsaPublicKey!)
                
                guard let message = self.ephemeralKeyRequest?.message
                    else {
                        self.ephemeralKeyRequest = nil
                        return
                }
                
                let parameters : [String: String] = ["kmsMessages" : message, "destination" : clusterUri]
                let header : [String: String]  = ["Cisco-Request-ID" : self.uuid,
                                                  "Authorization" : "Bearer " + self.accessTokenStr]
                
                let url = URL(string: self.kmsMessageServerUri)
                Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString(completionHandler: { (response) in
                    SDKLogger.shared.debug("Request EphemeralKey Response ============ \(response)")
                })
                
            }catch let error as NSError{
                self.ephemeralKeyRequest = nil
                SDKLogger.shared.debug("Error - RequestEphemeralKey \(error.description)")
            }
        }
    }
    
    // MARk: Message Operation Manage
    private func cancelAllPendingMessageOperations(result: Result<MessageModel>){
        for pendingOperation in self.pendingOperationList{
            let tempRes = ServiceResponse<MessageModel>(nil, result)
            pendingOperation.completionHandler(tempRes)
        }
        self.pendingOperationList.removeAll()
    }
    private func cancelPendingMessageOperationsFor(_ roomId: String, result: Result<MessageModel>){
        for pendingOperation in self.pendingOperationList{
            if(pendingOperation.message.roomId == roomId){
                let tempRes = ServiceResponse<MessageModel>(nil, result)
                pendingOperation.completionHandler(tempRes)
                self.pendingOperationList.removeObject(pendingOperation)
            }
        }
        for pendingListOperation in self.pendingListOperationList{
            if(pendingListOperation.roomId == roomId){
                let tempError = Result<[MessageModel]>.failure(result.error!)
                let tempRes = ServiceResponse<[MessageModel]>(nil, tempError)
                pendingListOperation.completionHandler(tempRes)
                self.pendingListOperationList.removeObject(pendingListOperation)
            }
        }
    }
    
    //MARK: - RequestBuilders
    private func messageServiceBuilder() -> ServiceRequest.MessageServerBuilder {
        return ServiceRequest.MessageServerBuilder(authenticator)
    }

    private func kmsRequestBuilder() -> ServiceRequest.KmsServerBuilder {
        return ServiceRequest.KmsServerBuilder(authenticator)
    }
    
    private var isClientReady: Bool{
        get{
            if let _ = self.kmsCluster,let _ = self.rsaPublicKey,let _ = self.userId{
                return true
            }else{
                return false
            }
        }
    }
    
    private func encryptKeyReadyFor(_ roomId: String) -> Bool{
        if let room = self.roomResourceList.filter({$0.roomId == roomId}).first{
            if let _ = room.encryptionUrl,let _ = room.keyMaterial{
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    private func readyToShareFor(_ roomId: String) -> Bool{
        if let room = self.roomResourceList.filter({$0.roomId == roomId}).first{
            if let _ = room.encryptionUrl,let _ = room.keyMaterial,let _ = room.spaceUrl{
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
}

