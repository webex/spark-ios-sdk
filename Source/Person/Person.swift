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

/// Person contents.
public struct Person: Mappable {
    
    /// The id of this person.
    public var id: String?
    
    /// The emails of this person.
    public var emails: [String]?
    
    /// The display name of this person.
    public var displayName: String?
    
    /// The avatar name of this person.
    public var avatar: String?
    
    /// The timestamp that this person being created.
    public var created: String?
    
    /// Person constructor.
    ///
    /// - note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Person mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        emails <- map["emails"]
        displayName <- map["displayName"]
        avatar <- map["avatar"]
        created <- map["created"]
    }
}