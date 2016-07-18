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

/// Team contents.
public struct Team: Mappable, Equatable {
    
    /// The id of this team.
    public var id: String?
    
    /// The name of this team
    public var name: String?
    
    /// The timestamp that this team being created.
    public var created: NSDate?
    
    /// Team constructor.
    ///
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Team mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}

/// Team Equatable implementation. Check if two teams are equal.
public func ==(lhs: Team, rhs: Team) -> Bool {
    if lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.created == rhs.created {
        return true
    }
    
    return false
}

