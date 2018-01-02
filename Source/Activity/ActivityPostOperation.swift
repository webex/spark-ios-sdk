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

class ActivityPostOperation: Operation {
    var messageActivity : MessageActivity
    var completionHandler :  (ServiceResponse<MessageActivity>) -> Void
    var queue : DispatchQueue?
    var keyMaterial : String?
    let authenticator: Authenticator
    init(authenticator: Authenticator, messageActivity: MessageActivity, keyMaterial: String?=nil , queue:DispatchQueue? = nil ,completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void) {
        self.authenticator = authenticator
        self.messageActivity = messageActivity
        self.queue = queue
        self.completionHandler = completionHandler
        self.keyMaterial = keyMaterial
        super.init()
        if(messageActivity.action == MessageAction.post && messageActivity.encryptionKeyUrl == nil){
            self.name = messageActivity.conversationId!
        }
    }
    
    override func main() {
        switch self.messageActivity.action! {
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
    
    private func postOperation(){
        let body = RequestParameter([
            "verb": "post",
            "encryptionKeyUrl" : self.messageActivity.encryptionKeyUrl!,
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
    
    private func shareOperation(){
        
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
            }
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
    
}
