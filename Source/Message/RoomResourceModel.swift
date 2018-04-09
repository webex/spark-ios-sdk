//
//  RoomResource.swift
//  SparkSDK
//
//  Created by qucui on 2018/1/2.
//  Copyright © 2018年 Cisco. All rights reserved.
//

import UIKit

class RoomResourceModel: NSObject {
    public var email: String
    public var roomId : String
    public var encryptionUrl: String?
    public var keyMaterial: String?
    public var spaceUrl: String?
    init(roomId: String) {
       self.roomId = roomId
       self.email = ""
    }
    init(email: String) {
        self.roomId = ""
        self.email = email
    }
    
}
