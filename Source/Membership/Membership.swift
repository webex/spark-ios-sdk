// Copyright 2016-2018 Cisco Systems Inc
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
public struct Membership {
    
    /// The id of this membership.
    ///
    /// - since: 1.2.0
    public var id: String?
    
    /// The id of the person.
    ///
    /// - since: 1.2.0
    public var personId: String?
    
    /// The email address of the person.
    ///
    /// - since: 1.2.0
    public var personEmail: EmailAddress?
    
    /// The id of the room.
    ///
    /// - since: 1.2.0
    public var roomId: String?
    
    /// Whether this member is a moderator of the room in this membership.
    ///
    /// - since: 1.2.0
    public var isModerator: Bool?
    
    /// Whether this member is a monitor of the room in this membership.
    ///
    /// - since: 1.2.0
    public var isMonitor: Bool?
    
    /// The timestamp that the membership being created.
    ///
    /// - since: 1.2.0
    public var created: Date?
    
    /// The display name of the person
    ///
    /// - since: 1.4.0
    public var personDisplayName : String?
    
    /// The personOrgId name of the person
    ///
    /// - since: 1.4.0
    public var personOrgId : String?
    
}

extension Membership : Mappable {
    
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
        personDisplayName <- map["personDisplayName"]
        personOrgId <- map["personOrgId"]
    }
}
