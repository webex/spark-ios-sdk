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

@available(*, deprecated, message: "Network calls should be made using the equivalent asynchronous calls on the client")
extension TeamMembershipClient {
    
    /// Lists all team memberships. By default, lists memberships for teams to which the authenticated user belongs.
    ///
    /// - parameter teamId: Limit results to a specific team, by ID.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - returns: TeamMembership array
    public func list(teamId: String, max: Int? = nil) throws -> [TeamMembership] {
        return try SyncUtil.getArray(authenticator, teamId, max, async: list)
    }
    
    /// Add someone to a team by Person ID; optionally making them a moderator.
    ///
    /// - parameter teamId: The team ID.
    /// - parameter personId: The person ID.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - returns: TeamMembership
	public func create(teamId: String, personId: String, isModerator: Bool = false) throws -> TeamMembership {
        return try SyncUtil.getObject(authenticator, teamId, personId, isModerator, async: create)
    }
    
    /// Add someone to a teams by email address; optionally making them a moderator.
    ///
    /// - parameter teamId: The team id.
    /// - parameter personEmail: The email address.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - returns: TeamMembership
    public func create(teamId: String, personEmail: EmailAddress, isModerator: Bool = false) throws -> TeamMembership {
        return try SyncUtil.getObject(authenticator, teamId, personEmail, isModerator, async: create)
    }
    
    /// Get details for a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - returns: TeamMembership
    public func get(membershipId: String) throws -> TeamMembership {
        return try SyncUtil.getObject(authenticator, membershipId, async: get)
    }
    
    /// Updates properties for a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - returns: TeamMembership
    public func update(membershipId: String, isModerator: Bool) throws -> TeamMembership {
        return try SyncUtil.getObject(authenticator, membershipId, isModerator, async: update)
    }
    
    /// Deletes a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - returns: Void
    public func delete(membershipId: String) throws {
        try SyncUtil.deleteObject(authenticator, membershipId, async: delete)
    }
}
