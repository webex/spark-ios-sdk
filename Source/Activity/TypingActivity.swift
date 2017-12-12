//
//  TypingActivity.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/12.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit
import ObjectMapper
/// The struct of a TypingStatus on Cisco Spark.
///
/// - since: 1.4.0
public enum TypingStatus : String{
    case StartTyping = "status.start_typing"
    case StopTyping = "status.stop_typing"
}

public class TypingActivity {
    
    public var action: TypingStatus?{
        return TypingStatus(rawValue: self.activityModel.eventType!)!
    }
    public var actor: ActivityActorModel?{
        return self.activityModel.actor
    }
    public var conversationID: String?{
        return self.activityModel.conversationId
    }
    private var activityModel: ActivityModel
    init(activitModel: ActivityModel) {
        self.activityModel = activitModel
    }
    public required convenience init?(map: Map){
        let acivitiModel = ActivityModel(map: map)
        self.init(activitModel: acivitiModel!)
    }
    public func mapping(map: Map) {
        self.activityModel <- map
    }
}
