//
//  ActivityRoomResource.swift
//  SparkSDK
//
//  Created by qucui on 2018/1/2.
//  Copyright © 2018年 Cisco. All rights reserved.
//

import UIKit

class AcitivityRoomResourceModel: NSObject {
    public var conversationId : String
    public var encryptionUrl: String?
    public var keyMaterial: String?
    public var spaceUrl: String?
    init(conversationId: String) {
       self.conversationId = conversationId
    }
}
