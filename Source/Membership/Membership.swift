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

/// Membership contents.
public struct Membership: Equatable {
    
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
    public var created: Date?
    
}

extension Membership: Mappable {
    
    /// Membership constructor.
    ///
    /// - note: for internal use only.
    public init?(map: Map){
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
