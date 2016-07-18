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

/// TeamMembership contents.
public struct TeamMembership: Mappable, Equatable {
    
    /// The id of this team membership.
    public var id: String?
    
    /// The id of the team.
    public var teamId: String?
    
    /// The id of the person.
    public var personId: String?
    
    /// The email address of the person.
    public var personEmail: EmailAddress?
    
    ///  The display name of the person.
    public var personDisplayName: String?
    
    /// Moderator of a team.
    public var isModerator: Bool?
    
    /// The timestamp that the team membership being created.
    public var created: NSDate?
    
    /// TeamMembership constructor.
    ///
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// TeamMembership mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        teamId <- map["teamId"]
        personId <- map["personId"]
        personEmail <- (map["personEmail"], EmailTransform())
        personDisplayName <- map["personDisplayName"]
        isModerator <- map["isModerator"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}

/// TeamMembership Equatable implementation. Check if two team memberships are equal.
public func ==(lhs: TeamMembership, rhs: TeamMembership) -> Bool {
    if lhs.id == rhs.id  &&
        lhs.personId == rhs.personId &&
        lhs.personEmail == rhs.personEmail &&
        lhs.personDisplayName == rhs.personDisplayName &&
        lhs.teamId == rhs.teamId &&
        lhs.isModerator == rhs.isModerator &&
        lhs.created == rhs.created  {
        return true
    }
    
    return false
}
