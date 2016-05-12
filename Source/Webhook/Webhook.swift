//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

/// Webhook contents.
public struct Webhook : Mappable {
    
    /// The id of this webhook.
    public var id: String?
    
    /// A user-friendly name for this webhook.
    public var name: String?
    
    /// The URL that receives POST requests for each event.
    public var targetUrl: String?
    
    /// The resource type for the webhook.
    public var resource: String?
    
    /// The event type for the webhook.
    public var event: String?
    
    /// The filter that defines the webhook scope.
    public var filter: String?
    
    /// The timestamp that the webhook being created.
    public var created: String?
    
    /// Webhook constructor.
    ///
    /// - note: for internal use only.
    public init?(_ map: Map) {
    }
    
    /// Webhook mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        targetUrl <- map["targetUrl"]
        resource <- map["resource"]
        event <- map["event"]
        name <- map["name"]
        filter <- map["filter"]
        created <- map["created"]
    }
}