//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension MembershipClient {
    
    /// Lists all room memberships. By default, lists memberships for rooms to which the authenticated user belongs.
    /// - Parameter roomId: Limit results to a specific room by id.
    /// - Parameter personId: Limit results to a specific person by id.
    /// - Parameter personEmail: Limit results to a specific person by email address.
    /// - Parameter max: Limit the maximum number of items in the response.
    /// - Returns: Memberships array
    public func list(roomId roomId: String? = nil, personId: String? = nil, personEmail: String? = nil, max: Int? = nil) throws -> [Membership] {
        return try SyncUtil.getArray(roomId, personId, personEmail, max, async: list)
    }
    
    /// Add someone to a room by person id; optionally making them a moderator.
    /// - Parameter roomId: The rooom id.
    /// - Parameter personId: The person id.
    /// - Parameter isModerator: Set to true to make the person a room moderator.
    /// - Returns: Membership
    public func createWithPersonId(roomId roomId: String, personId: String? = nil, isModerator: Bool? = nil) throws -> Membership {
        return try SyncUtil.getObject(roomId, personId, isModerator, async: createWithPersonId)
    }
    
    /// Add someone to a room by email address; optionally making them a moderator.
    /// - Parameter roomId: The rooom id.
    /// - Parameter personEmail: The email address.
    /// - Parameter isModerator: Set to true to make the person a room moderator.
    /// - Returns: Membership
    public func createWithPersonEmail(roomId roomId: String, personEmail: String? = nil, isModerator: Bool? = nil) throws -> Membership {
        return try SyncUtil.getObject(roomId, personEmail, isModerator, async: createWithPersonEmail)
    }
    
    /// Get details for a membership by id.
    /// - Parameter membershipId: The membership id.
    /// - Returns: Membership
    public func get(membershipId membershipId: String) throws -> Membership {
        return try SyncUtil.getObject(membershipId, async: get)
    }
    
    /// Updates properties for a membership by id.
    /// - Parameter membershipId: The membership id.
    /// - Parameter isModerator: Set to true to make the person a room moderator.
    /// - Returns: Membership
    public func update(membershipId membershipId: String, isModerator: Bool) throws -> Membership {
        return try SyncUtil.getObject(membershipId, isModerator, async: update)
    }
    
    /// Deletes a membership by id.
    /// - Parameter membershipId: The membership id.
    /// - Returns: Void
    public func delete(membershipId membershipId: String) throws {
        try SyncUtil.deleteObject(membershipId, async: delete)
    }
}