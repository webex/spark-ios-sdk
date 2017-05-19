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

/// A data type represents a Team at Cisco Spark cloud. 
///
/// - since: 1.2.0
public struct Team {
    
    /// The identifier of this team.
    ///
    /// - since: 1.2.0
    public var id: String?
    
    /// The name of this team
    ///
    /// - since: 1.2.0
    public var name: String?
    
    /// The timestamp that this team being created.
    ///
    /// - since: 1.2.0
    public var created: Date?
}

extension Team: Mappable {
    
    /// Constructs a *Team* object.
    ///
    /// - note: for internal use only.
    public init?(map: Map){
    }
    
    /// Map a *Team* from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}

