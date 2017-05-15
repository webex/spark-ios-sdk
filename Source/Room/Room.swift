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

/// The enumeration of the types of a room.
public enum RoomType: String {
    /// 1-to-1 room between two people
    case direct  = "direct"
    /// Group room among multiple people
    case group = "group"
}

/// A data type represents a Room at Cisco Spark cloud.
///
/// - note: Room has been renamed to Space in Cisco Spark.
/// - since: 1.2.0
public struct Room {
    /// The identifier of this room.
    ///
    /// - since: 1.2.0
    public var id: String?
    
    /// The title of this room.
    ///
    /// - since: 1.2.0
    public var title: String?
    
    /// The type of this room.
    ///
    /// - since: 1.2.0
    public var type: RoomType?
    
    /// Indicate if this room is locked.
    ///
    /// - since: 1.2.0
    public var isLocked: Bool?
    
    /// Last activity of this room.
    ///
    /// - since: 1.2.0
    public var lastActivity: String?
    
    /// The timestamp that this room being created.
    ///
    /// - since: 1.2.0
    public var created: Date?
    
    /// The team Id that this room associated with.
    ///
    /// - since: 1.2.0
    public var teamId: String?
}

extension Room: Mappable {
    
    /// Constructs a *Room* object.
    ///
    /// - note: for internal use only.
    public init?(map: Map){
    }
    
    /// Maps a *Room* from JSON.
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

