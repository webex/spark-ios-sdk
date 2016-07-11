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

extension TeamMembershipClient {
    
    /// Lists all team memberships. By default, lists memberships for teams to which the authenticated user belongs.
    ///
    /// - parameter teamId: Limit results to a specific team, by ID.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - returns: TeamMembership array
    public func list(teamId teamId: String, max: Int? = nil) throws -> [TeamMembership] {
        return try SyncUtil.getArray(teamId, max, async: list)
    }
    
    /// Add someone to a team by Person ID; optionally making them a moderator.
    ///
    /// - parameter teamId: The team ID.
    /// - parameter personId: The person ID.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - returns: TeamMembership
    public func create(teamId teamId: String, personId: String, isModerator: Bool? = nil) throws -> TeamMembership {
        return try SyncUtil.getObject(teamId, personId, isModerator, async: create)
    }
    
    /// Add someone to a teams by email address; optionally making them a moderator.
    ///
    /// - parameter teamId: The team id.
    /// - parameter personEmail: The email address.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - returns: TeamMembership
    public func create(teamId teamId: String, personEmail: EmailAddress, isModerator: Bool? = nil) throws -> TeamMembership {
        return try SyncUtil.getObject(teamId, personEmail, isModerator, async: create)
    }
    
    /// Get details for a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - returns: TeamMembership
    public func get(membershipId membershipId: String) throws -> TeamMembership {
        return try SyncUtil.getObject(membershipId, async: get)
    }
    
    /// Updates properties for a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - returns: TeamMembership
    public func update(membershipId membershipId: String, isModerator: Bool) throws -> TeamMembership {
        return try SyncUtil.getObject(membershipId, isModerator, async: update)
    }
    
    /// Deletes a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - returns: Void
    public func delete(membershipId membershipId: String) throws {
        try SyncUtil.deleteObject(membershipId, async: delete)
    }
}