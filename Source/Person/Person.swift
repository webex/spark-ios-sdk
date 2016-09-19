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

/// Person contents.
public struct Person: Mappable {
    
    /// The id of this person.
    public var id: String?
    
    /// The emails of this person.
    public var emails: [EmailAddress]?
    
    /// The display name of this person.
    public var displayName: String?
    
    /// The avatar name of this person.
    public var avatar: String?
    
    /// The timestamp that this person being created.
    public var created: Date?
    
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
    
    class EmailsTransform: TransformType {
        typealias Object = [EmailAddress]
        typealias JSON = [String]
        
        func transformFromJSON(_ value: Any?) -> Object?{
            var emails: [EmailAddress] = []
            let emailStrings = value as! [String]
            for emailString in emailStrings {
                emails.append(EmailAddress.fromString(emailString)!)
            }
            
            return emails
        }
        
        func transformToJSON(_ value: Object?) -> JSON? {
            return nil
        }
    }
}
