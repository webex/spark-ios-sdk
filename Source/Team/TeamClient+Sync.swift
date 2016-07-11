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

extension TeamClient {
    
    /// Lists teams to which the authenticated user belongs.
    ///
    /// - parameter max: Limit the maximum number of teams in the response.
    /// - returns: [Team]
    public func list(max: Int? = nil) throws -> [Team] {
        return try SyncUtil.getArray(max, async: list)
    }
    
    /// Creates a team. The authenticated user is automatically added as a member of the team. 
    /// See the Team Memberships API to learn how to add more people to the team.
    ///
    /// - parameter title: A user-friendly name for the team.
    /// - returns: Team
    public func create(name name: String) throws -> Team {
        return try SyncUtil.getObject(name, async: create)
    }
    
    
    /// Shows details for a team by id.
    ///
    /// - parameter teamId: A team id
    /// - returns: Team
    public func get(teamId teamId: String) throws -> Team {
        return try SyncUtil.getObject(teamId, async: get)
    }
    
    /// Updates details for a team, by ID.
    ///
    /// - parameter teamId: The team id.
    /// - parameter name: A user-friendly name for the team.
    /// - returns: Team
    public func update(teamId teamId: String, name: String) throws -> Team {
        return try SyncUtil.getObject(teamId, name, async: update)
    }
    
    /// Deletes a team, by ID.
    ///
    /// - parameter teamId: The team id.
    /// - returns: Void
    public func delete(teamId teamId: String) throws {
        try SyncUtil.deleteObject(teamId, async: delete)
    }
}