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

import Foundation
import ObjectMapper

/// A data type represents a relationship between *Team* and *Person* at Cisco Spark cloud.
///
/// - since: 1.2.0
public struct TeamMembership: Mappable, Equatable {
    
    /// The identifier of this team membership.
    ///
    /// - since: 1.2.0
    public var id: String?
    
    /// The identifier of the team.
    ///
    /// - since: 1.2.0
    public var teamId: String?
    
    /// The identifier of the person.
    ///
    /// - since: 1.2.0
    public var personId: String?
    
    /// The email address of the person.
    ///
    /// - since: 1.2.0
    public var personEmail: EmailAddress?
    
    ///  The display name of the person.
    ///
    /// - since: 1.2.0
    public var personDisplayName: String?
    
    /// True if the person in this membership is a moderator of the team.
    ///
    /// - since: 1.2.0
    public var isModerator: Bool?
    
    /// The timestamp that the team membership being created.
    ///
    /// - since: 1.2.0
    public var created: Date?
    
    /// Contructus a new *TeamMembership* object.
    ///
    /// - note: for internal use only.
    public init?(map: Map){
    }
    
    /// Maps a *TeamMembership* from JSON.
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

/// Checks whether the two *TeamMembership* have the same properties
/// This is the Equatable implementation for *TeamMembership*.
///
/// - return: True if the two team memberships are equal. Otherwise, false.
/// - since: 1.2.0
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
