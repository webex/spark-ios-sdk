// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import ObjectMapper

// Room type.
public enum RoomType: String {
    /// 1-to-1 room
    case Direct  = "direct"
    /// Group room
    case Group = "group"
}

/// Room contents.
public struct Room: Mappable {
    /// The id of this room.
    public var id: String?
    
    /// The title of this room.
    public var title: String?
    
    /// The type of this room.
    public var type: RoomType?
    
    /// Indicate if this room is locked.
    public var isLocked: Bool?
    
    /// Last activity of this room.
    public var lastActivity: String?
    
    /// The timestamp that this room being created.
    public var created: NSDate?
    
    /// The team Id that this room associated with.
    public var teamId: String?

    /// Room constructor.
    ///
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Room mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        type <- (map["type"], EnumTransform<RoomType>())
        isLocked <- map["isLocked"]
        lastActivity <- map["lastActivity"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
        teamId <- map["teamId"]
    }
}