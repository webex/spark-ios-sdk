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

/// Message contents.
public struct Message: Mappable {
    
    /// The id of this message.
    public var id: String?
    
    /// The person id.
    public var personId: String?
    
    /// The person email.
    public var personEmail: EmailAddress?
    
    /// The room id.
    public var roomId: String?
    
    /// The plain text message.
    public var text: String?
    
    /// A public URL that Spark can use to fetch attachments.
    public var files: [String]?
    
    /// The id of the recipient when sending a private1:1 message.
    public var toPersonId: String?
    
    /// The email address of the recipient when sendinga private 1:1 message.
    public var toPersonEmail: EmailAddress?
    
    /// The timestamp that the message being created.
    public var created: NSDate?
    
    /// Message constructor.
    ///
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Message mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        personId <- map["personId"]
        personEmail <- (map["personEmail"], EmailTransform())
        roomId <- map["roomId"]
        text <- map["text"]
        files <- map["files"]
        toPersonId <- map["toPersonId"]
        toPersonEmail <- (map["toPersonEmail"], EmailTransform())
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}

class EmailTransform: TransformType {
    typealias Object = EmailAddress
    typealias JSON = String
    
    func transformFromJSON(value: AnyObject?) -> Object?{
        return EmailAddress.fromString(value as! String)
    }
    
    func transformToJSON(value: Object?) -> JSON? {
        return nil
    }
}
