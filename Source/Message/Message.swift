// Copyright 2016 Cisco Systems Inc
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
    
    /// The id of the recipient when sending a private 1:1 message.
    public var toPersonId: String?
    
    /// The email address of the recipient when sending a private 1:1 message.
    public var toPersonEmail: EmailAddress?
    
    /// The timestamp that the message being created.
    public var created: Date?
    
    /// Message constructor.
    ///
    /// - note: for internal use only.
    public init?(map: Map){
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
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if let value = value as? String {
            return EmailAddress.fromString(value)
        } else {
            return nil
        }
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        return nil
    }
}
