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
    public var created: NSDate?
    
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
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}