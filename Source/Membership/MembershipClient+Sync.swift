//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension MembershipClient {
    
    /// Lists all room memberships. By default, lists memberships for rooms to which the authenticated user belongs.
    ///
    /// - parameter roomId: Limit results to a specific room by id.
    /// - parameter personId: Limit results to a specific person by id.
    /// - parameter personEmail: Limit results to a specific person by email address.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - returns: Memberships array
    public func list(roomId roomId: String? = nil, personId: String? = nil, personEmail: String? = nil, max: Int? = nil) throws -> [Membership] {
        return try SyncUtil.getArray(roomId, personId, personEmail, max, async: list)
    }
    
    /// Add someone to a room by person id; optionally making them a moderator.
    ///
    /// - parameter roomId: The rooom id.
    /// - parameter personId: The person id.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - returns: Membership
    public func createWithPersonId(roomId roomId: String, personId: String? = nil, isModerator: Bool? = nil) throws -> Membership {
        return try SyncUtil.getObject(roomId, personId, isModerator, async: createWithPersonId)
    }
    
    /// Add someone to a room by email address; optionally making them a moderator.
    ///
    /// - parameter roomId: The rooom id.
    /// - parameter personEmail: The email address.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - returns: Membership
    public func createWithPersonEmail(roomId roomId: String, personEmail: String? = nil, isModerator: Bool? = nil) throws -> Membership {
        return try SyncUtil.getObject(roomId, personEmail, isModerator, async: createWithPersonEmail)
    }
    
    /// Get details for a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - returns: Membership
    public func get(membershipId membershipId: String) throws -> Membership {
        return try SyncUtil.getObject(membershipId, async: get)
    }
    
    /// Updates properties for a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - returns: Membership
    public func update(membershipId membershipId: String, isModerator: Bool) throws -> Membership {
        return try SyncUtil.getObject(membershipId, isModerator, async: update)
    }
    
    /// Deletes a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - returns: Void
    public func delete(membershipId membershipId: String) throws {
        try SyncUtil.deleteObject(membershipId, async: delete)
    }
}