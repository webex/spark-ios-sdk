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

/// Membership contents.
public struct Membership: Mappable, Equatable {
    
    /// The id of this membership.
    public var id: String?
    
    /// The id of the person.
    public var personId: String?
    
    /// The email address of the person.
    public var personEmail: EmailAddress?
    
    /// The id of the room.
    public var roomId: String?
    
    /// Moderator of a room.
    public var isModerator: Bool?
    
    /// Monitor of a room.
    public var isMonitor: Bool?
    
    /// The timestamp that the membership being created.
    public var created: NSDate?
    
    /// Membership constructor.
    ///
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Membership mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        personId <- map["personId"]
        personEmail <- (map["personEmail"], EmailTransform())
        roomId <- map["roomId"]
        isModerator <- map["isModerator"]
        isMonitor <- map["isMonitor"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}

/// Membership Equatable implementation. Check if two memberships are equal.
public func ==(lhs: Membership, rhs: Membership) -> Bool {
    if lhs.id == rhs.id  &&
        lhs.personId == rhs.personId &&
        lhs.personEmail == rhs.personEmail &&
        lhs.roomId == rhs.roomId &&
        lhs.isModerator == rhs.isModerator &&
        lhs.isMonitor == rhs.isMonitor &&
        lhs.created == rhs.created  {
        return true
    }
    
    return false
}
