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