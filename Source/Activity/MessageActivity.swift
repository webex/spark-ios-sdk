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
}

/// The struct of a MentionItemType on Cisco Spark.
///
/// - since: 1.4.0
public enum MentionItemType : String{
    case person = "person"
    case group = "group"
}

public class MessageActivity: Mappable {

    /// The action of this message activity.
    ///
    /// - since: 1.4.0
    public var action: MessageAction?{
        return MessageAction(rawValue: self.activityModel.verb!)
    }
    /// The actor who created this activity.
    ///
    /// - since: 1.4.0
    public var actor: ActivityActorModel?{
        return self.activityModel.actor
    }
    /// Where target where this activity sent to.
    ///
    /// - since: 1.4.0
    public var target: ActivityTargetModel?{
        return self.activityModel.target
    }
    
    /// id of this activty
    ///
    /// - since: 1.4.0
    public var activityId: String?{
        return self.activityModel.id
    }
    
    /// url of this activity.
    ///
    /// - since: 1.4.0
    public var activityUrl: String?{
        return self.activityModel.url
    }
    
    /// craate date of this activity
    ///
    /// - since: 1.4.0
    public var publishedDate: Date?{
        return self.activityModel.published
    }
    
    /// plain text without markup
    ///
    /// - since: 1.4.0
    public var plainText: String?
    
    /// encryptionKeyUrl of this activity
    ///
    /// - since: 1.4.0
    public var encryptionKeyUrl: String?{
        return self.activityModel.encryptionKeyUrl
    }
    
    /// target conversation id of this activity
    ///
    /// - since: 1.4.0
    public var conversationId: String?{
        if(self.activityModel.conversationId != nil){
            return self.activityModel.conversationId
        }else{
            if self.target != nil{
                if(target?.objectType == "conversation"){
                    return target?.id
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }
    }
    
    /// markup text of this activity
    ///
    /// - since: 1.4.0
    public var markUpText: String?{
        return self.activityModel.object?.content
    }
    
    /// mention item list of this activity
    ///
    /// - since: 1.4.0
    public var mentionItems: [ActivityMentionModel]?
    
    
    private var activityModel: ActivityModel
    init(activitModel: ActivityModel) {
        self.activityModel = activitModel
        self.markDownString()
    }
    
    
    public required convenience init?(map: Map){
        let acivitiModel = Mapper<ActivityModel>().map(JSON: map.JSON)
        self.init(activitModel: acivitiModel!)
        self.markDownString()
    }
    public func mapping(map: Map) {
        self.activityModel <- map
    }
    
    /// convert mark up text in to plain text
    ///
    /// - since: 1.4.0
    private func markDownString(){
        var markDownContent = ""
        self.mentionItems = [ActivityMentionModel]()
        if let mentions = self.activityModel.object?.mentions , let content = self.activityModel.object?.content{
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
                
                var mentionItem = mentionArr[index]
                let startPosition = markDownContent.distance(from: markDownContent.startIndex, to: startSyntaxIndex!)
                let range = startPosition...(startPosition+mentionContentString.count-1)
                mentionItem.range = range
                
                self.mentionItems?.append(mentionItem)
            }
        }
        self.plainText = markDownContent
    }
}



