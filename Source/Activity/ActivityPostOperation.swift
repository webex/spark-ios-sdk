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


class ActivityPostOperation: Operation {
    var messageActivity : MessageActivity
    var completionHandler :  (ServiceResponse<MessageActivity>) -> Void
    var queue : DispatchQueue?
    var keyMaterial : String?
    var action : MessageAction?
    var encryptionUrl : String?
    let authenticator: Authenticator
    var files : [URL]?
    var spaceUrl: String?
    var fileModelArray: [FileObjectModel]?
    init(authenticator: Authenticator, messageActivity: MessageActivity, keyMaterial: String?=nil, spaceUrl: String? = nil ,queue:DispatchQueue? = nil ,completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void) {
        self.authenticator = authenticator
        self.messageActivity = messageActivity
        self.action = messageActivity.action
        self.encryptionUrl = messageActivity.encryptionKeyUrl
        self.queue = queue
        self.completionHandler = completionHandler
        self.keyMaterial = keyMaterial
        if(messageActivity.action == MessageAction.share){
            self.spaceUrl = spaceUrl
            self.fileModelArray = [FileObjectModel]()
            self.files = messageActivity.localFileList
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
                self.shareOperation()
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
    
    private func shareOperation(){
        guard let spaceUrl = self.spaceUrl,
            let files = self.files else{
                return
        }
        
        self.authenticator.accessToken { token in
            let header : [String: String]  = ["Authorization" : "Bearer " + token!]
            let uploadSessionUrl = URL(string: spaceUrl+"/upload_sessions")
            var fileSize: UInt64 = 0
            do{
                SDKLogger.shared.info("Uploading File Data ......")
                for localUrl in files{
                    let fileAttr = try FileManager.default.attributesOfItem(atPath: localUrl.absoluteString)
                    fileSize = fileAttr[FileAttributeKey.size] as! UInt64
                    let nsInputStream = InputStream(fileAtPath: localUrl.absoluteString)
                    let fileScr = try SecureContentReference(error: ())
                    let secureInputStream = try SecureInputStream(stream: nsInputStream, scr: fileScr)
                    let parameters : Parameters = [ "fileSize": fileSize ]
                    Alamofire.request(uploadSessionUrl!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { response in
                        switch response.result{
                        case .success(let value):
                            if let dict = value as? [String : Any]{
                                let uploadUrl = URL(string: dict["uploadUrl"] as! String)
                                let finishUrl = URL(string: dict["finishUploadUrl"] as! String)
                                
                                let uploadheadHeader: HTTPHeaders = ["Content-Length": String(fileSize)]
                                Alamofire.upload(secureInputStream, to: uploadUrl!, method: .put, headers: uploadheadHeader).responseString(completionHandler: { (response) in
                                    let finishHead: HTTPHeaders = [ "Authorization" : "Bearer " + token!,
                                                                    "Content-Type": "application/json;charset=UTF-8"]
                                    let pramDict = ["size":fileSize]
                                    do{
                                        var request = try Alamofire.URLRequest(url: finishUrl!, method: .post, headers: finishHead)
                                        let pramData = try JSONSerialization.data(withJSONObject: pramDict, options: .prettyPrinted)
                                        request.httpBody = pramData
                                        Alamofire.request(request).responseJSON(completionHandler: { (response) in
                                            switch response.result{
                                            case .success(let value):
                                                if let dict = value as? [String : Any]{
                                                    let fileUrl = dict["url"] as! String
                                                    let downLoadUrl = dict["downloadUrl"] as! String
                                                    self.finishUploadFile(localUrl: localUrl, fileSize: fileSize,fileUrl: fileUrl, downloadUrl: downLoadUrl, fileScr: fileScr,accessToken: token!)
                                                }
                                                break
                                            case .failure:
                                                break
                                            }
                                        })
                                    } catch{}
                                })
                            }
                            break
                        case .failure(let error):
                            SDKLogger.shared.debug("error: \(error.localizedDescription)")
                            self.cancel()
                            break
                        }
                    })
                    
                }
            }catch let error as NSError{
                SDKLogger.shared.debug("File Create Error - \(error.description)")
                self.cancel()
            }
        }
    }
    private func finishUploadFile(localUrl: URL, fileSize: UInt64,fileUrl: String, downloadUrl: String, fileScr: SecureContentReference,accessToken: String){
        SDKLogger.shared.info("Finish Up load Data")
        do{
            let fileName = try CjoseWrapper.ciphertext(fromContent: localUrl.lastPathComponent.data(using: .utf8), key: self.keyMaterial!)
            fileScr.loc = URL(string: downloadUrl)!
            let chiperfileSrc = try fileScr.encryptedSecureContentReference(withKey: self.keyMaterial!)
            let mimeType = self.mimeType(fromFilename: localUrl.lastPathComponent)
            
            var fileDict : [String : Any] = ["displayName" : fileName,
                                             "objectType" : "file",
                                             "mimeType": mimeType,
                                             "fileSize": fileSize,
                                             "scr" : chiperfileSrc,
                                             "url" : downloadUrl]
            if(mimeType.hasPrefix("image") || mimeType.hasPrefix("documents")){
                let imageDict : [String : Any] = ["mimeType": "image/png",
                                                  "scr" : chiperfileSrc,
                                                  "url" : downloadUrl,
                                                  "height": 900,
                                                  "width" : 640]
                fileDict["image"] = imageDict
            }
            
            let fileObj = FileObjectModel(JSON: fileDict)
            self.fileModelArray?.append(fileObj!)
            
            if(self.fileModelArray?.count == self.files?.count){
                guard let encryptionUrl = self.encryptionUrl else {
                    return
                }
                let header : [String: String]  = ["Authorization" : "Bearer " + accessToken]
                let body = RequestParameter([
                    "verb": "share",
                    "encryptionKeyUrl" : encryptionUrl,
                    "object" : createActivityObject(objectType: "content",messagaActivity: self.messageActivity).toJSON(),
                    "target" : createActivityTarget(conversationId: self.messageActivity.conversationId).toJSON()
                    ])
                let request = requestBuilder()
                    .headers(header)
                    .method(.post)
                    .body(body)
                    .queue(self.queue)
                    .build()
                request.responseObject(self.completionHandler)
            }
        }catch{
            self.cancel()
        }
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
        var model = ActivityObjectModel()
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
                        mentionStringLength += (markupStr.count - mentionContent.count) + 1
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
                let displayNameChiper = try CjoseWrapper.ciphertext(fromContent: model.content?.data(using: .utf8), key: keyMaterial)
                let contentChiper = try CjoseWrapper.ciphertext(fromContent: model.content?.data(using: .utf8), key: keyMaterial)
                model.displayName = displayNameChiper
                model.content = contentChiper
            }catch let error as NSError {
                SDKLogger.shared.debug("Process Activity Error - \(error.description)")
                self.cancel()
            }
        }
        
        if let fileDictList = self.fileModelArray{
            model.contentCategory = "documents"
            model.objectType = "content"
            model.files = ["items" : fileDictList]
        }
        return model
    }
    
    private func createActivityTarget(conversationId: String? = nil) -> ActivityTargetModel{
        var model = ActivityTargetModel()
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

