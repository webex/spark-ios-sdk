//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

/// Membership contents.
public struct Membership: Mappable {
    
    /// The id of this membership.
    public var id: String?
    
    /// The id of the person.
    public var personId: String?
    
    /// The email address of the person.
    public var personEmail: String?
    
    /// The id of the room.
    public var roomId: String?
    
    /// Moderator of a room.
    public var isModerator: Bool?
    
    /// Monitor of a room.
    public var isMonitor: Bool?
    
    /// The timestamp that the membership being created.
    public var created: String?
    
    /// Membership constructor.
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Membership mapping from JSON.
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        personId <- map["personId"]
        personEmail <- map["personEmail"]
        roomId <- map["roomId"]
        isModerator <- map["isModerator"]
        isMonitor <- map["isMonitor"]
        created <- map["created"]
    }
}
