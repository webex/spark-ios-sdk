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

extension PersonClient {
    
    /// List people in your organization.
    ///
    /// - parameter email: List people with this email address.
    /// - parameter displayName: List people whose name starts with this string.
    /// - parameter max: Limit the maximum number of people in the response.
    /// - returns: People array
    public func list(email email: String? = nil, displayName: String? = nil, max: Int? = nil) throws -> [Person] {
        return try SyncUtil.getArray(email, displayName, max, async: list)
    }
    
    /// Shows details for a person by id.
    ///
    /// - parameter personId: A person id
    /// - returns: Person
    public func get(personId personId: String) throws -> Person {
        return try SyncUtil.getObject(personId, async: get)
    }
    
    /// Show the profile for the authenticated user.
    ///
    /// - returns: Person
    public func getMe() throws -> Person {
        return try SyncUtil.getObject(getMe)
    }
}