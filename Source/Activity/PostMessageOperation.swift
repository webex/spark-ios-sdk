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
    var messageActivity : MessageActivity
    var uploadingProgressHandler : ((FileObjectModel, Double) -> Void)? = nil
    var completionHandler :  (ServiceResponse<MessageActivity>) -> Void
    var queue : DispatchQueue?
    var keyMaterial : String?
    var action : MessageAction?
    var encryptionUrl : String?
    let authenticator: Authenticator
    var files : [FileObjectModel]?
    var spaceUrl: String?
    init(authenticator: Authenticator,
         messageActivity: MessageActivity,
         keyMaterial: String?=nil,
         spaceUrl: String? = nil,
         queue:DispatchQueue? = nil,
         uploadingProgressHandler : ((FileObjectModel, Double) -> Void)? = nil,
         completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        self.authenticator = authenticator
        self.messageActivity = messageActivity
        self.action = messageActivity.action
        self.encryptionUrl = messageActivity.encryptionKeyUrl
        self.queue = queue
        self.completionHandler = completionHandler
        self.keyMaterial = keyMaterial
        if(messageActivity.action == MessageAction.share){
            self.spaceUrl = spaceUrl
            self.files = messageActivity.files
            self.uploadingProgressHandler = uploadingProgressHandler
        }
        super.init()
        if(self.action == MessageAction.post && self.encryptionUrl == nil){
            self.name = messageActivity.conversationId!
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
        case .acknowledge:
            self.readOperation()
            break
        case .delete:
            self.deleteOperation()
            break
        default:
            self.cancel()
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
                        let result = Result<MessageActivity>.failure(err)
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
            "object" : createActivityObject(objectType: "comment",messagaActivity: self.messageActivity).toJSON(),
            "target" : createActivityTarget(conversationId: self.messageActivity.conversationId).toJSON()
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(self.queue)
            .build()
        request.responseObject(self.completionHandler)
    }
    
    private func postOperation(){
        guard let encryptionUrl = self.encryptionUrl else {
            return
        }
        let body = RequestParameter([
            "verb": "post",
            "encryptionKeyUrl" : encryptionUrl,
            "object" : createActivityObject(objectType: "comment",messagaActivity: self.messageActivity).toJSON(),
            "target" : createActivityTarget(conversationId: self.messageActivity.conversationId).toJSON()
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(self.queue)
            .build()
        request.responseObject(self.completionHandler)
    }
    
    
    private func readOperation(){
        let body = RequestParameter([
            "verb": "acknowledge",
            "object" : createActivityObject(objectType: "activity", messagaActivity: self.messageActivity).toJSON(),
            "target" : createActivityTarget(conversationId: self.messageActivity.conversationId).toJSON()
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
            "object" : createActivityObject(objectType: "activity", messagaActivity: self.messageActivity).toJSON(),
            "target" : createActivityTarget(conversationId: self.messageActivity.conversationId).toJSON()
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(self.queue)
            .build()
        request.responseObject(self.completionHandler)
    }
    
    
    // MARK: Client Private Functions
    private func createActivityObject(objectType: String,
                                      messagaActivity: MessageActivity) -> ActivityObjectModel
    {
        let model = ActivityObjectModel()
        model.objectType = objectType
        if let objectIdStr = messagaActivity.activityId{
            model.id = objectIdStr
        }
        if let contentStr = messagaActivity.plainText{
            var markedUpContent = contentStr
            if let mentionsArr = messagaActivity.mentionItems{
                var mentionStringLength = 0
                for index in 0..<mentionsArr.count{
                    let mentionItem = mentionsArr[index]
                    if(mentionItem.mentionType == MentionItemType.person){
                        let startPosition = (mentionItem.range.lowerBound) + mentionStringLength
                        let endPostion = (mentionItem.range.upperBound) + mentionStringLength
                        let startIndex = markedUpContent.index(markedUpContent.startIndex, offsetBy: startPosition)
                        let endIndex = markedUpContent.index(markedUpContent.startIndex, offsetBy: endPostion)
                        let mentionContent = markedUpContent[startPosition..<endPostion]
                        let markupStr = markUpString(mentionContent: mentionContent, mentionId: mentionItem.id, mentionType: "person")
                        markedUpContent = markedUpContent.replacingCharacters(in: startIndex..<endIndex, with: markupStr)
                        mentionStringLength += (markupStr.count - mentionContent.count)
                    }else{
                        /// group mention codes goes heere
                    }
                }
                model.content = markedUpContent
                model.displayName = contentStr
                model.mentions =  ["items" : mentionsArr]
            }else{
                model.content = contentStr
                model.displayName = contentStr
            }
        }
        if let keyMaterial = self.keyMaterial{
            do {
                if(model.content != nil && model.content != ""){
                    let displayNameChiper = try CjoseWrapper.ciphertext(fromContent: model.displayName?.data(using: .utf8), key: keyMaterial)
                    let contentChiper = try CjoseWrapper.ciphertext(fromContent: model.content?.data(using: .utf8), key: keyMaterial)
                    model.displayName = displayNameChiper
                    model.content = contentChiper
                }
            }catch let error as NSError {
                SDKLogger.shared.debug("Process Posting Activity Error - \(error.description)")
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
                model.contentCategory = "documents"
                model.objectType = "content"
                model.files = ["items" : files]
            }catch let error as NSError {
                SDKLogger.shared.debug("Process Posting Activity Files Error - \(error.description)")
                self.cancel()
            }
        }
        return model
    }
    
    private func createActivityTarget(conversationId: String? = nil) -> ActivityTargetModel{
        let model = ActivityTargetModel()
        model.objectType = "conversation"
        if let idStr = conversationId{
            model.id = idStr
        }
        return model
    }
    
    private func markUpString(mentionContent: String?, mentionId: String?, mentionType: String?)->String{
        var result = "<spark-mention"
        if let mentionid = mentionId{
            result = result + " data-object-id=" + mentionid
        }
        if let type = mentionType{
            result = result + " data-object-type=" + type
        }
        result = result + ">"
        if let content = mentionContent{
            result = result + content
        }
        result = result + "</spark-mention>"
        return result
    }
    
    private func requestBuilder() -> ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator).path("activities")
    }
    
    private func mimeType(fromFilename filename: String) -> String {
        let defaultMimeType = "application/octet-stream"
        guard let fileType = filename.split(separator: ".").last else{
            return defaultMimeType
        }
        
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileType as CFString, nil)?.takeRetainedValue(),
            let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeUnretainedValue() else {
                return defaultMimeType
        }
        
        return mimeType as String
    }
    
}

