//
//  Activity.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/12.
//  Copyright © 2017年 Cisco. All rights reserved.
//
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

    public var action: MessageAction?{
        return MessageAction(rawValue: self.activityModel.verb!)
    }
    /// The person who sent this *message*.
    ///
    /// - since: 1.4.0
    public var from: ActivityActorModel?{
        return self.activityModel.actor
    }
    /// Where who sent this *message*.
    ///
    /// - since: 1.4.0
    public var target: ActivityTargetModel?{
        return self.activityModel.target
    }
    
    /// Where who sent this *message*.
    ///
    /// - since: 1.4.0
    public var activityId: String?{
        return self.activityModel.id
    }
    
    /// Where who sent this *message*.
    ///
    /// - since: 1.4.0
    public var activityUrl: String?{
        return self.activityModel.url
    }
    
    /// Where who sent this *message*.
    ///
    /// - since: 1.4.0
    public var publishedDate: Date?{
        return self.activityModel.published
    }
    
    public var plainText: String?{
        return self.activityModel.object?.displayName
    }
    
    public var encryptionKeyUrl: String?{
        return self.activityModel.encryptionKeyUrl
    }
    
    public var conversationId: String?{
        return self.activityModel.conversationId
    }
    
    public var markUpText: String?
    
    public var mentionItems: [ActivityMentionModel]?
    
    
    private var activityModel: ActivityModel
    init(activitModel: ActivityModel) {
        self.activityModel = activitModel
    }
    
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
        self.markUpText = markDownContent
    }
    
    
    public required convenience init?(map: Map){
        let acivitiModel = ActivityModel(map: map)
        self.init(activitModel: acivitiModel!)
        self.markDownString()
    }
    public func mapping(map: Map) {
        self.activityModel <- map
    }
}



