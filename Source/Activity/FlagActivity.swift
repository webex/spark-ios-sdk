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
        let acivitiModel = Mapper<ActivityModel>().map(JSON: map.JSON)
        self.init(activitModel: acivitiModel!)
    }
    public func mapping(map: Map) {
        self.activityModel <- map
    }
}
