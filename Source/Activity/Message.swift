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

/// The struct of a MentionItemType on Cisco Spark.
///
/// - since: 1.4.0
public enum MessageAction : String{
    case acknowledge = "acknowledge"
    case post = "post"
    case share = "share"
    case delete = "delete"
    case update = "update"
    case none = "none"
}

/// The struct of a MentionItemType on Cisco Spark.
///
/// - since: 1.4.0
public enum MentionItemType : String{
    case person = "person"
    case group = "group"
}

public class Message: Mappable {
    
    /// The action of this message.
    ///
    /// - since: 1.4.0
    public var action: MessageAction?{
        get {
            return MessageAction(rawValue:self.messageModel.verb!)
        }
        set{
            self.messageModel.verb = newValue?.rawValue
        }
    }
    
    /// The actor who created this message.
    ///
    /// - since: 1.4.0
    public var actor: MessageActorModel?{
        return self.messageModel.actor
    }
    /// Where target where this message sent to.
    ///
    /// - since: 1.4.0
    public var target: MessageTargetModel?{
        return self.messageModel.target
    }
    
    /// id of this activty
    ///
    /// - since: 1.4.0
    public var messageId: String?{
        get {
            return self.messageModel.id
        }
        set{
            self.messageModel.id = newValue
        }
    }
    
    /// url of this message.
    ///
    /// - since: 1.4.0
    public var messageUrl: String?{
        return self.messageModel.url
    }
    
    /// craate date of this message
    ///
    /// - since: 1.4.0
    public var publishedDate: Date?{
        return self.messageModel.published
    }
    
    /// plain text without markup
    ///
    /// - since: 1.4.0
    public var plainText: String?
    
    
    /// file uploading local file path
    ///
    /// - since: 1.4.0
    public var files: [FileObjectModel]?
    
    /// encryptionKeyUrl of this message
    ///
    /// - since: 1.4.0
    public var encryptionKeyUrl: String?{
        get {
            return self.messageModel.encryptionKeyUrl
        }
        set{
            self.messageModel.encryptionKeyUrl = newValue
        }
    }
    
    /// target conversation id of this message
    ///
    /// - since: 1.4.0
    public var conversationId: String?{
        get{
            if(self.messageModel.conversationId != nil){
                return self.messageModel.conversationId
            }else if self.target != nil{
                if(target?.objectType == "conversation"){
                    return target?.id
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }
        set{
            self.messageModel.conversationId = newValue
        }
    }
    
    /// markup text of this message
    ///
    /// - since: 1.4.0
    public var markUpText: String?{
        return self.messageModel.object?.content
    }
    
    
    /// mention item list of this message
    ///
    /// - since: 1.4.0
    public var mentionItems: [MessageMentionModel]?
    
    private var messageModel: MessageModel
    
    init(){
        self.messageModel = MessageModel()
    }
    
    init(activitModel: MessageModel) {
        self.messageModel = activitModel
        if(self.action == .post || self.action == .share){
            if let content = self.messageModel.object?.content{
                self.plainText = content
            }else{
                if let displayName = self.messageModel.object?.displayName{
                    self.plainText = displayName
                }
            }
        }else{
            self.plainText = ""
        }
        
        if(self.action == .share){
            if let files = self.messageModel.object?.files!["items"]{
                self.files = files
            }
        }
    }
    
    public required convenience init?(map: Map){
        let acivitiModel = Mapper<MessageModel>().map(JSON: map.JSON)
        self.init(activitModel: acivitiModel!)
    }
    
    public func mapping(map: Map) {
        self.messageModel <- map
    }
    
    /// convert mark up text in to plain text
    ///
    /// - since: 1.4.0
    public func markDownString(){
        var markDownContent = ""
        if let mentions = self.messageModel.object?.mentions , let content = self.plainText{
            self.mentionItems = [MessageMentionModel]()
            markDownContent = content
            let mentionArr = mentions["items"]!
            for index in 0 ..< mentionArr.count{
                let startSyntaxIndex = markDownContent.range(of: "<spark-mention")?.lowerBound
                let endSyntaxRange = markDownContent.range(of: "</spark-mention>")?.upperBound
                let subString = markDownContent.substring(with: startSyntaxIndex..<endSyntaxRange)
                
                let mentionContentBeginIndex = subString.range(of: ">")?.upperBound
                let mentionContentEndIndex = subString.range(of: "</spark-mention>")?.lowerBound
                let mentionContentString = subString.substring(with: mentionContentBeginIndex..<mentionContentEndIndex)
                
                markDownContent = markDownContent.replacingCharacters(in: startSyntaxIndex..<endSyntaxRange, with: mentionContentString)
                
                let mentionItem = mentionArr[index]
                let startPosition = markDownContent.distance(from: markDownContent.startIndex, to: startSyntaxIndex!)
                let range = startPosition...(startPosition+mentionContentString.count-1)
                mentionItem.range = range
                
                self.mentionItems?.append(mentionItem)
            }
        }
        if(markDownContent != ""){
            self.plainText = markDownContent
        }
    }
}

