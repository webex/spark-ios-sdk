//
//  FlagActivity.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/12.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit
import ObjectMapper
/// The struct of a FlagItemStatus on Cisco Spark.
///
/// - since: 1.4.0
public enum FlagStatus:String{
    case FlagCreated = "create"
    case FlagDeleted = "delete"
}

public class FlagActivity : Mappable{

    public var action: FlagStatus?{
        return FlagStatus(rawValue: self.activityModel.action!)
    }
    
    public var flagItemUrl: String?{
        return self.activityModel.flagItem?.activityUrl
    }
    public var flagUrl: String?{
        return self.activityModel.flagItem?.url
    }
    public var flagItemId: String?{
        return self.activityModel.flagItem?.id
    }
    public var createdDate: Date?{
        return self.activityModel.flagItem?.created
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
