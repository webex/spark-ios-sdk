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

/// Person contents.
public struct Person {
    
    /// The id of this person.
    public var id: String?
    
    /// The emails of this person.
    public var emails: [EmailAddress]?
    
    /// The display name of this person.
    public var displayName: String?
    
    /// The URL of this person's avatar.
    public var avatar: String?
    
    /// The timestamp that this person being created.
    public var created: Date?
    
    class EmailsTransform: TransformType {
        
        func transformFromJSON(_ value: Any?) -> [EmailAddress]? {
            var emails: [EmailAddress] = []

            guard let value = (value as? [String]) else {
                return nil
            }

            for emailString in value {
                if let emailAddress = EmailAddress.fromString(emailString) {
                    emails.append(emailAddress)
                } else {
                    SDKLogger.shared.warn("\(emailString) is not a properly formatted email address")
                }
            }
            return emails
        }
        
        func transformToJSON(_ value: [EmailAddress]?) ->  [String]? {
            var emails: [String] = []
            guard value != nil else {
                return nil
            }
            for email in value! {
                emails.append(email.toString())
            }
            return emails
        }
    }
}

extension Person: Mappable {
    
    /// Person constructor.
    ///
    /// - note: for internal use only.
    public init?(map: Map){
    }
    
    /// Person mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        emails <- (map["emails"], EmailsTransform())
        displayName <- map["displayName"]
        avatar <- map["avatar"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}
