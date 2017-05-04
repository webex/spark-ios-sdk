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

/// A data type presents a Webhook at Cisco Spark for Developer.
///
/// - see: see [Webhook Explained](https://developer.ciscospark.com/webhooks-explained.html)
/// - since: 1.2.0
public struct Webhook : Mappable {
    
    /// The identifier of this webhook.
    ///
    /// - since: 1.2.0
    public var id: String?
    
    /// A user-friendly name for this webhook.
    ///
    /// - since: 1.2.0
    public var name: String?
    
    /// The URL that receives POST requests for each event.
    ///
    /// - since: 1.2.0
    public var targetUrl: String?
    
    /// The resource type for the webhook.
    ///
    /// - since: 1.2.0
    public var resource: String?
    
    /// The event type for the webhook.
    ///
    /// - since: 1.2.0
    public var event: String?
    
    /// The filter that defines the webhook scope.
    ///
    /// - since: 1.2.0
    public var filter: String?
    
    /// The timestamp that the webhook being created.
    ///
    /// - since: 1.2.0
    public var created: Date?
    
    /// Constructs a new *Webhook* object.
    ///
    /// - note: for internal use only.
    public init?(map: Map) {
    }
    
    /// Maps a *Webhook from JSON.
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
