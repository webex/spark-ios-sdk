//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

/// Person contents.
public struct Person: Mappable {
    
    /// The id of this person.
    public var id: String?
    
    /// The emails of this person.
    public var emails: [String]?
    
    /// The display name of this person.
    public var displayName: String?
    
    /// The avatar name of this person.
    public var avatar: String?
    
    /// The timestamp that this person being created.
    public var created: String?
    
    /// Person constructor.
    /// - Note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Person mapping from JSON.
    /// - Note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        emails <- map["emails"]
        displayName <- map["displayName"]
        avatar <- map["avatar"]
        created <- map["created"]
    }
}