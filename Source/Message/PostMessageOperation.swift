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
import Alamofire
import MobileCoreServices.UTCoreTypes
import MobileCoreServices.UTType

class PostMessageOperation: Operation {
    var message : MessageModel
    var uploadingProgressHandler : ((FileObjectModel, Double) -> Void)? = nil
    var completionHandler :  (ServiceResponse<MessageModel>) -> Void
    var queue : DispatchQueue?
    var keyMaterial : String?
    var action : MessageAction?
    var encryptionUrl : String?
    let authenticator: Authenticator
    var files : [FileObjectModel]?
    var spaceUrl: String?
    var response: ServiceResponse<MessageModel>?
    
    init(authenticator: Authenticator,
         message: MessageModel,
         keyMaterial: String?=nil,
         spaceUrl: String? = nil,
         queue:DispatchQueue? = nil,
         uploadingProgressHandler : ((FileObjectModel, Double) -> Void)? = nil,
         completionHandler: @escaping (ServiceResponse<MessageModel>) -> Void)
    {
        self.authenticator = authenticator
        self.message = message
        self.action = message.messageAction
        self.encryptionUrl = message.encryptionKeyUrl
        self.queue = queue
        self.completionHandler = completionHandler
        self.keyMaterial = keyMaterial
        if(message.messageAction == MessageAction.share){
            self.spaceUrl = spaceUrl
            self.files = message.files
            self.uploadingProgressHandler = uploadingProgressHandler
        }
        super.init()
        if(self.action == MessageAction.post && self.encryptionUrl == nil){
            self.name = message.roomId!
        }
    }
    
    override func main() {
        guard let action = self.action else {
            self.cancel()
            return
        }
        switch action {
        case .post:
            if(self.keyMaterial == nil){
                self.cancel()
            }else{
                self.postOperation()
            }
            break
        case .share:
            if(self.keyMaterial == nil){
                self.cancel()
            }else{
                self.upLoadOperation()
            }
        case .delete:
            self.deleteOperation()
            break
        }
    }
    
    private func upLoadOperation(){
        guard let spaceUrl = self.spaceUrl,
            let files = self.files else{
                return
        }
        self.authenticator.accessToken { token in
            for file in files{
                let uploadOperation = UploadFileOperation(token: token!, spaceUrl: spaceUrl, fileModel: file, keyMatiarial: self.keyMaterial! ,progressHandler: { (progress) in
                    if let progressHandler = self.uploadingProgressHandler{
                        progressHandler(file, progress)
                    }
                }, completionHandler: { (file, error) in
                    if let err = error {
                        self.cancel()
                        let result = Result<MessageModel>.failure(err)
                        self.completionHandler(ServiceResponse(nil, result))
                    }else{
                        self.finishUploadFile()
                    }
                })
                uploadOperation.start()
            }
        }
    }
    private func finishUploadFile(){
        if ((self.files?.filter({$0.url == nil}).first) != nil){
            return
        }else{
            self.shareOperation()
        }
    }
    
    private func shareOperation(){
        guard let encryptionUrl = self.encryptionUrl else {
            return
        }
        let body = RequestParameter([
            "verb": "share",
            "encryptionKeyUrl" : encryptionUrl,
            "object" : createMessageObject(objectType: "comment",message: self.message),
            "target" : createMessageTarget(roomId: self.message.roomId)
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(self.queue)
            .build()
        request.responseObject{ (response: ServiceResponse<MessageModel>) in
            self.response = response
            switch response.result{
            case .success(let value):
                self.decrypt(value)
                break
            case .failure(_):
                self.completionHandler(response)
                break
            }
        }
    }
    
    private func postOperation(){
        guard let encryptionUrl = self.encryptionUrl else {
            return
        }
        let body = RequestParameter([
            "verb": "post",
            "encryptionKeyUrl" : encryptionUrl,
            "object" : createMessageObject(objectType: "comment",message: self.message),
            "target" : createMessageTarget(roomId: self.message.roomId)
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(self.queue)
            .build()
        request.responseObject{ (response: ServiceResponse<MessageModel>) in
            self.response = response
            switch response.result{
            case .success(let value):
                self.decrypt(value)
                break
            case .failure(_):
                self.completionHandler(response)
                break
            }
        }
    }
    
    
    private func readOperation(){
        let body = RequestParameter([
            "verb": "acknowledge",
            "object" : createMessageObject(objectType: "activity", message: self.message),
            "target" : createMessageTarget(roomId: self.message.roomId)
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(self.queue)
            .build()
        request.responseObject(self.completionHandler)
    }
    
    
    private func deleteOperation(){
        let body = RequestParameter([
            "verb": "delete",
            "object" : createMessageObject(objectType: "activity", message: self.message),
            "target" : createMessageTarget(roomId: self.message.roomId)
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(self.queue)
            .build()
        request.responseObject(self.completionHandler)
    }
    
    
    // MARK: Client Private Functions
    private func requestBuilder() -> ServiceRequest.MessageServerBuilder {
        return ServiceRequest.MessageServerBuilder(authenticator).path("activities")
    }
    private func createMessageObject(objectType: String, message: MessageModel) -> [String: Any]
    {
        var objectDict = [String: Any]()
        objectDict["objectType"] = objectType
        if let objectIdStr = message.id{
            objectDict["id"] = objectIdStr.sparkSplitString()
        }
        objectDict["displayName"] = message.text
        if let htmlStr = message.html{
            objectDict["content"] = htmlStr
        }else{
            objectDict["content"] = message.text
        }
        if let peopleMentionArr = message.mentionedPeople{
            var tempArray = [[String: String]]()
            for peopleMention in peopleMentionArr{
                var dict = [String: String]()
                dict["id"] = peopleMention.sparkSplitString()
                dict["objectType"] = "person"
                tempArray.append(dict)
            }
            objectDict["mentions"] =  ["items" : tempArray]
        }
        if let groupMentionArr = message.mentionedGroup{
            var tempArray = [[String: String]]()
            for groupType in groupMentionArr{
                var dict = [String: String]()
                dict["groupType"] = groupType
                dict["objectType"] = "groupMention"
                tempArray.append(dict)
            }
            objectDict["groupMentions"] =  ["items" : tempArray]
        }
        
        if let keyMaterial = self.keyMaterial{
            do {
                if(objectDict["content"] != nil){
                    let displayNameChiper = try CjoseWrapper.ciphertext(fromContent: (objectDict["displayName"] as? String)?.data(using: .utf8), key: keyMaterial)
                    let contentChiper = try CjoseWrapper.ciphertext(fromContent: (objectDict["content"] as? String)?.data(using: .utf8), key: keyMaterial)
                    objectDict["displayName"] = displayNameChiper
                    objectDict["content"] = contentChiper
                }
            }catch let error as NSError {
                SDKLogger.shared.debug("Process Posting Message Error - \(error.description)")
                self.cancel()
            }
        }
        
        if let files = self.files{
            do {
                for file in files{
                    if let displayName = file.displayName{
                        file.mimeType = self.mimeType(fromFilename: displayName)
                    }else{
                        file.mimeType = self.mimeType(fromFilename: "")
                    }
                    let chiperFileName = try CjoseWrapper.ciphertext(fromContent: file.displayName?.data(using: .utf8), key: keyMaterial)
                    file.displayName = chiperFileName
                }
                objectDict["contentCategory"] = "documents"
                objectDict["objectType"] = "content"
                objectDict["files"] = ["items" : files.toJSON()]
            }catch let error as NSError {
                SDKLogger.shared.debug("Process Posting Message Files Error - \(error.description)")
                self.cancel()
            }
        }
        return objectDict
    }
    private func createMessageTarget(roomId: String? = nil) -> [String: Any]{
        var objectDict = [String: Any]()
        objectDict["objectType"] = "conversation"
        if let idStr = roomId{
            objectDict["id"] = idStr.sparkSplitString()
        }
        return objectDict
    }
    private func mimeType(fromFilename filename: String) -> String {
        let defaultMimeType = "application/octet-stream"
        guard let fileType = filename.components(separatedBy: ".").last else{
            return defaultMimeType
        }
        
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileType as CFString, nil)?.takeRetainedValue(),
            let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeUnretainedValue() else {
                return defaultMimeType
        }
        
        return mimeType as String
    }
    
    private func decrypt(_ newMessage: MessageModel){
        guard let acitivityKeyMaterial = self.keyMaterial else{
            return
        }
        do {
            if newMessage.text == nil{
                newMessage.text = ""
            }
            guard let chiperText = newMessage.text
                else{
                    return
            }
            if(chiperText != ""){
                let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
                let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
                newMessage.text = clearText! as String
            }
            if let files = newMessage.files{
                for file in files{
                    if let displayname = file.displayName,
                        let scr = file.scr
                    {
                        let nameData = try CjoseWrapper.content(fromCiphertext: displayname, key: acitivityKeyMaterial)
                        let clearName = NSString(data:nameData ,encoding: String.Encoding.utf8.rawValue)! as String
                        let srcData = try CjoseWrapper.content(fromCiphertext: scr, key: acitivityKeyMaterial)
                        let clearSrc = NSString(data:srcData ,encoding: String.Encoding.utf8.rawValue)! as String
                        if let image = file.image{
                            let imageSrcData = try CjoseWrapper.content(fromCiphertext: image.scr, key: acitivityKeyMaterial)
                            let imageClearSrc = NSString(data:imageSrcData ,encoding: String.Encoding.utf8.rawValue)! as String
                            image.scr = imageClearSrc
                        }
                        file.displayName = clearName
                        file.scr = clearSrc
                    }
                }
                newMessage.files = files
            }
        }catch{}
        self.completionHandler(self.response!)
    }
}
