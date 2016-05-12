//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

/// Message contents.
public struct Message: Mappable {
    
    /// The id of this message.
    public var id: String?
    
    /// The person id.
    public var personId: String?
    
    /// The person email.
    public var personEmail: String?
    
    /// The room id.
    public var roomId: String?
    
    /// The plain text message.
    public var text: String?
    
    /// A public URL that Spark can use to fetch attachments.
    public var files: [String]?
    
    /// The id of the recipient when sending a private1:1 message.
    public var toPersonId: String?
    
    /// The email address of the recipient when sendinga private 1:1 message.
    public var toPersonEmail: String?
    
    /// The timestamp that the message being created.
    public var created: String?
    
    /// Message constructor.
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Message mapping from JSON.
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        personId <- map["personId"]
        personEmail <- map["personEmail"]
        roomId <- map["roomId"]
        text <- map["text"]
        files <- map["files"]
        toPersonId <- map["toPersonId"]
        toPersonEmail <- map["toPersonEmail"]
        created <- map["files"]
    }
}