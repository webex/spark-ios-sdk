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
import ObjectMapper
import Alamofire
import SwiftyJSON

class MessageClientImpl {
    
    class MSGError {
        static let roomFetchFail = SparkError.serviceFailed(code: -7000, reason: "Room Fetch Fail")
        static let clientInfoFetchFail = SparkError.serviceFailed(code: -7000, reason: "Client Info Fetch Fail")
        static let ephemaralKeyFetchFail = SparkError.serviceFailed(code: -7000, reason: "EphemaralKey Fetch Fail")
        static let kmsInfoFetchFail = SparkError.serviceFailed(code: -7000, reason: "KMS Info Fetch Fail")
        static let keyMaterialFetchFail = SparkError.serviceFailed(code: -7000, reason: "Key Info Fetch Fail")
        static let encryptionUrlFetchFail = SparkError.serviceFailed(code: -7000, reason: "Encryption Info Fetch Fail")
        static let spaceUrlFetchFail = SparkError.serviceFailed(code: -7000, reason: "Space Info Fetch Fail")
        static let emptyTextError = SparkError.serviceFailed(code: -7000, reason: "Expected Text Not Found")
        static let downloadError = SparkError.serviceFailed(code: -7000, reason: "Expected File Not Found")
        static let Timeout = SparkError.serviceFailed(code: -7000, reason: "Timeout")
    }
    
    private enum ObjectType : String {
        case activity
        case comment
        case content
        case conversation
    }
    
    private static let KMS_MSG_SERVER_URL = URL(string: ServiceRequest.KMS_SERVER_ADDRESS + "/kms/messages")!
    
    /// Callback when receive Message.
    ///
    /// - since: 1.4.0
    public var onEvent: ((MessageEvent) -> Void)?
    
    let authenticator: Authenticator
    var deviceUrl : URL
    
    private let queue = SerialQueue()
    
    private var uuid: String = UUID().uuidString
    private var userId : String?
    private var kmsCluster: String?
    private var rsaPublicKey: String?
    private var ephemeralKey: String?
    
    private var ephemeralKeyRequest: (KmsEphemeralKeyRequest, (Error?) -> Void)?
    private var keyMaterialCompletionHandlers: [String: (Result<(String, String)>) -> Void] = [String: (Result<(String, String)>) -> Void]()
    private var keysCompletionHandlers: [String: (Result<(String, String)>) -> Void] = [String: (Result<(String, String)>) -> Void]()
    private var encryptionKeys: [String: EncryptionKey] = [String: EncryptionKey]()
    private var rooms: [String: String] = [String: String]()
    
    init(authenticator: Authenticator, deviceUrl: URL) {
        self.authenticator = authenticator
        self.deviceUrl = deviceUrl
    }
    
    func list(roomId: String,
              sinceDate: String? = nil,
              maxDate: String? = nil,
              midDate: String? = nil,
              limit: Int? = nil,
              personRefresh: Bool? = false,
              lastMessageFirst: Bool? = true,
              queue: DispatchQueue? = nil,
              completionHandler: @escaping (ServiceResponse<[Message]>) -> Void) {
    
        let query = RequestParameter([
            "conversationId": roomId.locusFormat,
            "sinceDate": sinceDate,
            "maxDate": maxDate,
            "midDate": midDate,
            "limit": limit,
            "personRefresh": personRefresh,
            "lastActivityFirst": lastMessageFirst,
            ])
    
        let request = self.messageServiceBuilder.path("activities")
            .keyPath("items")
            .method(.get)
            .query(query)
            .queue(queue)
            .build()
        
        request.responseArray { (response: ServiceResponse<[ActivityModel]>) in
            switch response.result {
            case .success(let activities):
                let key = self.encryptionKey(roomId: roomId)
                key.material(client: self) { material in
                    if let material = material.data {
                        let messages = activities.filter({$0.kind == ActivityModel.Kind.post || $0.kind == ActivityModel.Kind.share})
                            .map { $0.decrypt(key: material) }
                            .map { Message(activity: $0) }
                        (queue ?? DispatchQueue.main).async {
                            completionHandler(ServiceResponse(response.response, Result.success(messages)))
                        }
                    }
                    else {
                        (queue ?? DispatchQueue.main).async {
                            completionHandler(ServiceResponse(response.response, Result.failure(material.error ?? MSGError.keyMaterialFetchFail)))
                        }
                    }
                }
            case .failure(let error):
                completionHandler(ServiceResponse(response.response, Result.failure(error)))
            }
        }
    }
    
    func get(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        let request = self.messageServiceBuilder.path("activities")
            .method(.get)
            .path(messageId.locusFormat)
            .queue(queue)
            .build()
        request.responseObject { (response : ServiceResponse<ActivityModel>) in
            switch response.result {
            case .success(let activity):
                if let roomId = activity.roomId {
                    let key = self.encryptionKey(roomId: roomId)
                    key.material(client: self) { material in
                        (queue ?? DispatchQueue.main).async {
                            completionHandler(ServiceResponse(response.response, Result.success(Message(activity: activity.decrypt(key: material.data)))))
                        }
                    }
                }
                else {
                    completionHandler(ServiceResponse(response.response, Result.failure(response.result.error ?? MSGError.roomFetchFail)))
                }
            case .failure(let error):
                completionHandler(ServiceResponse(response.response, Result.failure(error)))
            }
        }
    }

    func post(email: String,
              text: String? = nil,
              mentions: [Mention]? = nil,
              files: [LocalFile]? = nil,
              queue: DispatchQueue? = nil,
              completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        self.lookupRoom(email: email, queue: queue) { result in
            if let roomId = result.data {
                self.post(roomId: roomId, text: text, mentions: mentions, files: files, queue: queue, completionHandler: completionHandler)
            }
            else {
                completionHandler(ServiceResponse(nil, Result.failure(result.error ?? MSGError.roomFetchFail)))
            }
        }
    }
    
    func post(roomId: String,
              text: String? = nil,
              mentions: [Mention]? = nil,
              files: [LocalFile]? = nil,
              queue: DispatchQueue? = nil,
              completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        var object = [String: Any]()
        object["objectType"] = ObjectType.comment.rawValue
        object["displayName"] = text
        object["content"] = text
        var mentionedGroup = [[String: String]]()
        var mentionedPeople = [[String: String]]()
        mentions?.forEach { mention in
            switch mention {
            case .all:
                mentionedGroup.append(["objectType": "groupMention", "groupType": "all"])
            case .person(let person):
                mentionedPeople.append(["objectType": "person", "id": person.locusFormat])
            }
        }
        object["mentions"] = ["items" : mentionedPeople]
        object["groupMentions"] = ["items" : mentionedGroup]
        
        var verb = ActivityModel.Kind.post
        let key = self.encryptionKey(roomId: roomId)
        key.material(client: self) { material in
            if let material = material.data, let encrypt = text?.encrypt(key: material) {
                object["displayName"] = encrypt
                object["content"] = encrypt
            }
            let opeations = UploadFileOperations(key: key, files: files ?? [LocalFile]())
            opeations.run(client: self) { result in
                if let files = result.data, files.count > 0 {
                    // TODO
                    object["objectType"] = ObjectType.content.rawValue
                    object["contentCategory"] = "documents"
                    object["files"] = ["items": files.toJSON()]
                    verb = ActivityModel.Kind.share
                }
                let target: [String: Any] = ["id": roomId.locusFormat, "objectType": ObjectType.conversation.rawValue]
                key.encryptionUrl(client: self) { encryptionUrl in
                    if let url = encryptionUrl.data {
                        let body = RequestParameter(["verb": verb.rawValue, "encryptionKeyUrl": url, "object": object, "target": target])
                        let request = self.messageServiceBuilder.path("activities")
                            .method(.post)
                            .body(body)
                            .queue(queue)
                            .build()
                        request.responseObject { (response: ServiceResponse<ActivityModel>) in
                            switch response.result{
                            case .success(let activity):
                                completionHandler(ServiceResponse(response.response, Result.success(Message(activity: activity.decrypt(key: material.data)))))
                            case .failure(let error):
                                completionHandler(ServiceResponse(response.response, Result.failure(error)))
                            }
                        }
                    }
                    else {
                        (queue ?? DispatchQueue.main).async {
                            completionHandler(ServiceResponse(nil, Result.failure(encryptionUrl.error ?? MSGError.encryptionUrlFetchFail)))
                        }
                    }
                }
            }
        }
    }
    
    func delete(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = self.messageServiceBuilder.path("activities")
            .method(.get)
            .path(messageId.locusFormat)
            .queue(queue)
            .build()
        request.responseObject { (response : ServiceResponse<ActivityModel>) in
            switch response.result {
            case .success(let activity):
                if let roomId = activity.roomId {
                    let object: [String: Any] = ["id": messageId.locusFormat, "objectType": ObjectType.activity.rawValue]
                    let target: [String: Any] = ["id": roomId.locusFormat, "objectType": ObjectType.conversation.rawValue]
                    let body = RequestParameter(["verb": ActivityModel.Kind.delete.rawValue, "object": object, "target": target])
                    let request = self.messageServiceBuilder.path("activities")
                        .method(.post)
                        .body(body)
                        .queue(queue)
                        .build()
                    request.responseJSON(completionHandler)
                }
                else {
                    (queue ?? DispatchQueue.main).async {
                        completionHandler(ServiceResponse(response.response, Result.failure(response.result.error ?? MSGError.roomFetchFail)))
                    }
                }
            case .failure(let error):
                completionHandler(ServiceResponse(response.response, Result.failure(error)))
                break
            }
        }
    }

    func downloadFile(file: RemoteFile, to: URL? = nil, queue: DispatchQueue? = nil, progressHandler: ((Double)->Void)? = nil, completionHandler: @escaping (Result<URL>) -> Void) {
        if let source = file.url {
            let operation = DownloadFileOperation(authenticator: self.authenticator,
                                                  uuid: self.uuid,
                                                  source: source,
                                                  secureContentRef: file.secureContentRef,
                                                  thnumnail: false,
                                                  target: to,
                                                  queue: queue,
                                                  progressHandler: progressHandler,
                                                  completionHandler: completionHandler)
            operation.run()
        }
        else {
            completionHandler(Result.failure(MSGError.downloadError))
        }
    }
    
    func downloadThumbnail(file: RemoteFile, to: URL? = nil,  queue: DispatchQueue? = nil, progressHandler: ((Double)->Void)? = nil, completionHandler: @escaping (Result<URL>) -> Void) {
        if let source = file.thumbnail?.url {
            let operation = DownloadFileOperation(authenticator: self.authenticator,
                                                  uuid: self.uuid,
                                                  source: source,
                                                  secureContentRef: file.thumbnail?.secureContentRef,
                                                  thnumnail: true,
                                                  target: to,
                                                  queue: queue,
                                                  progressHandler: progressHandler,
                                                  completionHandler: completionHandler)
            operation.run()
        }
        else {
            completionHandler(Result.failure(MSGError.downloadError))
        }
    }
    
    // MARK: Encryption Feature Functions
    func handle(activity: ActivityModel) {
        guard let roomId = activity.roomId else {
            SDKLogger.shared.error("Not a room message \(activity.id ?? (activity.toJSONString() ?? ""))")
            return
        }
        let key = self.encryptionKey(roomId: roomId)
        if let encryptionUrl = activity.encryptionKeyUrl {
            key.tryRefresh(encryptionUrl: encryptionUrl)
        }
        key.material(client: self) { material in
            let decryption = activity.decrypt(key: material.data)
            guard let kind = decryption.kind else {
                SDKLogger.shared.error("Not a valid message \(activity.id ?? (activity.toJSONString() ?? ""))")
                return
            }
            DispatchQueue.main.async {
                switch kind {
                case .post, .share:
                    self.onEvent?(MessageEvent.messageReceived(Message(activity: decryption)))
                case .delete:
                    self.onEvent?(MessageEvent.messageDeleted(decryption.id ?? "illegal id"))
                default:
                    SDKLogger.shared.error("Not a valid message \(activity.id ?? (activity.toJSONString() ?? ""))")
                }
            }
        }
    }
    
    func handle(kms: KmsMessageModel) {
        if let response = kms.kmsMessages?.first {
            if let request = self.ephemeralKeyRequest {
                if let key = try? KmsEphemeralKeyResponse(responseMessage: response, request: request.0).jwkEphemeralKey {
                    self.ephemeralKey = key
                    request.1(nil)
                }
                else {
                    request.1(MSGError.ephemaralKeyFetchFail)
                }
                self.ephemeralKeyRequest = nil
            }
            else if let key = self.ephemeralKey, let data = try? CjoseWrapper.content(fromCiphertext: response, key: key), let json = try? JSON(data: data) {
                if let key = json["key"].object as? [String:Any] {
                    if let jwk = key["jwk"], let uri = key["uri"], let keyMaterial = JSON(jwk).rawString(),
                        let keyUri = JSON(uri).rawString(),
                        let handler = self.keyMaterialCompletionHandlers.removeValue(forKey: keyUri) {
                        handler(Result.success((keyUri, keyMaterial)))
                    }
                    else if let dict = (json["keys"].object as? [[String : Any]])?.first {
                        if let key = try? KmsKey(from: dict), let handler = self.keysCompletionHandlers.popFirst()?.value {
                            handler(Result.success((key.uri, key.jwk)))
                        }
                    }
                }
            }
        }
    }
    
    func requestRoomEncryptionURL(roomId: String, completionHandler: @escaping (Result<String>) -> Void) {
        self.prepareEncryptionKey { error in
            if let error = error {
                completionHandler(Result.failure(error))
                return
            }
            self.authenticator.accessToken { token in
                guard let token = token else {
                    completionHandler(Result.failure(SparkError.noAuth))
                    return
                }
                // TODO remove token
                let request = self.messageServiceBuilder.path("conversations/" + roomId.locusFormat)
                    .query(RequestParameter(["includeActivities": false, "includeParticipants": false]))
                    .headers(["Authorization": "Bearer " + token])
                    .method(.get)
                    .build()
                request.responseJSON { (response: ServiceResponse<Any>) in
                    if let dict = response.result.data as? [String: Any], let encryptionUrl = (dict["encryptionKeyUrl"] ?? dict["defaultActivityEncryptionKeyUrl"]) as? String {
                        completionHandler(Result.success(encryptionUrl))
                    }
                    else {
                        completionHandler(Result.failure(response.result.error ?? MSGError.encryptionUrlFetchFail))
                    }
                }
            }
        }
    }
    
    func requestRoomKeyMaterial(roomId: String, encryptionUrl: String?, completionHandler: @escaping (Result<(String, String)>) -> Void) {
        self.prepareEncryptionKey { error in
            if let error = error {
                completionHandler(Result.failure(error))
                return
            }
            self.authenticator.accessToken { token in
                guard let token = token else {
                    completionHandler(Result.failure(SparkError.noAuth))
                    return
                }
                guard let userId = self.userId, let ephemeralKey = self.ephemeralKey else {
                    completionHandler(Result.failure(MSGError.ephemaralKeyFetchFail))
                    return
                }
                let header: [String: String]  = ["Cisco-Request-ID": self.uuid, "Authorization": "Bearer " + token]
                var parameters: [String: Any]?
                var failed: () -> Void
                if let encryptionUrl = encryptionUrl {
                    if let request = try? KmsRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString, userId: userId, bearer: token, method: "retrieve", uri: encryptionUrl),
                        let serialize = request.serialize(),
                        let chiperText = try? CjoseWrapper.ciphertext(fromContent: serialize.data(using: .utf8), key: ephemeralKey) {
                        parameters = ["kmsMessages": [chiperText], "destination": "unused" ] as [String : Any]
                        self.keyMaterialCompletionHandlers[encryptionUrl] = completionHandler
                    }
                    failed = {
                        self.keyMaterialCompletionHandlers[encryptionUrl] = nil
                        completionHandler(Result.failure(MSGError.keyMaterialFetchFail))
                    }
                }
                else {
                    if let request = try? KmsRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString, userId: userId, bearer: token, method: "create", uri: "/keys") {
                        request.additionalAttributes = ["count": 1]
                        if let serialize = request.serialize(), let chiperText = try? CjoseWrapper.ciphertext(fromContent: serialize.data(using: .utf8), key: ephemeralKey) {
                            parameters = ["kmsMessages": [chiperText], "destination": "unused" ] as [String: Any]
                            self.keysCompletionHandlers[roomId] = completionHandler
                        }
                    }
                    failed = {
                        self.keysCompletionHandlers[roomId] = nil
                        completionHandler(Result.failure(MSGError.keyMaterialFetchFail))
                    }
                }
                if let parameters = parameters, parameters.count >= 2 {
                    Alamofire.request(MessageClientImpl.KMS_MSG_SERVER_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString { (response) in
                        SDKLogger.shared.debug("RequestKMS Material Response ============  \(response)")
                        if response.result.isFailure {
                            failed()
                        }
                    }
                }
                else {
                    failed()
                }
            }
        }
    }
    
    private func prepareEncryptionKey(completionHandler: @escaping (Error?) -> Void) {
        func validateResult(_ error: Error?) -> Bool {
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                self.queue.yield()
                return false
            }
            return true
        }
        self.queue.sync {
            self.requestUserId { error in
                if validateResult(error) {
                    self.requestClusterAndRSAPubKey { error in
                        if validateResult(error) {
                            self.requestEphemeralKey { error in
                                if validateResult(error) {
                                    self.queue.yield()
                                    DispatchQueue.main.async {
                                        completionHandler(nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func requestUserId(completionHandler: @escaping (Error?) -> Void) {
        if self.userId != nil {
            completionHandler(nil)
            return
        }
        let request = self.messageServiceBuilder.path("users")
            .method(.get)
            .build()
        request.responseJSON { (response: ServiceResponse<Any>) in
            if let usersDict = response.result.data as? [String: Any], let userId = usersDict["id"] as? String {
                self.userId = userId
                completionHandler(nil)
            }
            else {
                completionHandler(MSGError.clientInfoFetchFail)
            }
        }
    }
    
    private func requestClusterAndRSAPubKey(completionHandler: @escaping (Error?) -> Void) {
        if self.kmsCluster != nil && self.rsaPublicKey != nil {
            completionHandler(nil)
            return
        }
        let request =  ServiceRequest.Builder(self.authenticator).baseUrl(ServiceRequest.KMS_SERVER_ADDRESS).path("kms")
            .method(.get)
            .build()
        request.responseJSON { (response: ServiceResponse<Any>) in
            if let kmsDict = response.result.data as? [String: Any], let kmsCluster = kmsDict["kmsCluster"] as? String, let rsaPublicKey = kmsDict["rsaPublicKey"] as? String {
                self.kmsCluster = kmsCluster
                self.rsaPublicKey = rsaPublicKey
                completionHandler(nil)
            }
            else {
                completionHandler(MSGError.clientInfoFetchFail)
            }
        }
    }
    
    private func requestEphemeralKey(completionHandler: @escaping (Error?) -> Void) {
        if self.ephemeralKey != nil {
            completionHandler(nil)
            return
        }
        self.authenticator.accessToken { token in
            guard let token = token else {
                completionHandler(MSGError.ephemaralKeyFetchFail)
                return
            }
            if (self.ephemeralKeyRequest != nil) {
                SDKLogger.shared.debug("Request EphemeralKey duplicated")
                completionHandler(MSGError.ephemaralKeyFetchFail)
                return
            }
            guard let userId = self.userId, let cluster = self.kmsCluster, let clusterURI = URL(string: cluster), let rsaPubKey = self.rsaPublicKey else {
                SDKLogger.shared.debug("Request EphemeralKey failed")
                completionHandler(MSGError.ephemaralKeyFetchFail)
                return
            }
            let ecdhe = clusterURI.appendingPathComponent("ecdhe").absoluteString
            guard let request = try? KmsEphemeralKeyRequest(requestId: self.uuid, clientId: self.deviceUrl.absoluteString , userId: userId, bearer: token , method: "create", uri: ecdhe, kmsStaticKey: rsaPubKey), let message = request.message else {
                SDKLogger.shared.debug("Request EphemeralKey failed, illegal ephemeral key request")
                completionHandler(MSGError.ephemaralKeyFetchFail)
                return
            }
            self.ephemeralKeyRequest = (request, completionHandler)
            let parameters: [String: String] = ["kmsMessages": message, "destination": cluster]
            let header: [String: String]  = ["Cisco-Request-ID": self.uuid, "Authorization" : "Bearer " + token]
            Alamofire.request(MessageClientImpl.KMS_MSG_SERVER_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseString { response in
                SDKLogger.shared.debug("Request EphemeralKey Response ============ \(response)")
                if response.result.isFailure {
                    self.ephemeralKeyRequest = nil
                    completionHandler(MSGError.ephemaralKeyFetchFail)
                }
            }
        }
    }
    
    private var messageServiceBuilder: ServiceRequest.Builder {
        return ServiceRequest.Builder(self.authenticator).baseUrl(ServiceRequest.CONVERSATION_SERVER_ADDRESS)
    }
    
    private func encryptionKey(roomId: String) -> EncryptionKey {
        var key = self.encryptionKeys[roomId]
        if key == nil {
            key = EncryptionKey(roomId: roomId)
            self.encryptionKeys[roomId] = key
        }
        return key!
    }
    
    private func lookupRoom(email: String, queue: DispatchQueue?, completionHandler: @escaping (Result<String>) -> Void) {
        if let roomId = self.rooms[email] {
            (queue ?? DispatchQueue.main).async {
                completionHandler(Result.success(roomId))
            }
        }
        else {
            let query = RequestParameter(["activitiesLimit": 0, "compact": true])
            let path = "conversations/user/" + email
            let request = self.messageServiceBuilder.path(path)
                .method(.put)
                .query(query)
                .queue(queue)
                .build()
            request.responseObject { (response: ServiceResponse<Room>) in
                if let room = response.result.data?.id {
                    let roomId = room.hydraFormat(for: .room)
                    self.rooms[email] = roomId
                    completionHandler(Result.success(roomId))
                }
                else {
                    completionHandler(Result.failure(response.result.error ?? MSGError.roomFetchFail))
                }
            }
        }
    }
}
