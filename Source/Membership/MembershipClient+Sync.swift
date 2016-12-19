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

@available(*, deprecated, message: "Network calls should be made using the equivalent asynchronous calls on the client")
extension MembershipClient {
    
    /// Lists all room memberships. By default, lists memberships for rooms to which the authenticated user belongs.
    ///
    /// - parameter roomId: Limit results to a specific room by id.
    /// - parameter personId: Limit results to a specific person by id.
    /// - parameter personEmail: Limit results to a specific person by email address.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - returns: Memberships array
    public func list(roomId: String? = nil, personId: String? = nil, personEmail: EmailAddress? = nil, max: Int? = nil) throws -> [Membership] {
        return try SyncUtil.getArray(authenticationStrategy, roomId, personId, personEmail, max, async: list)
    }
    
    /// Add someone to a room by person id; optionally making them a moderator.
    ///
    /// - parameter roomId: The rooom id.
    /// - parameter personId: The person id.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - returns: Membership
    public func create(roomId: String, personId: String, isModerator: Bool = false) throws -> Membership {
        return try SyncUtil.getObject(authenticationStrategy, roomId, personId, isModerator, async: create)
    }
    
    /// Add someone to a room by email address; optionally making them a moderator.
    ///
    /// - parameter roomId: The rooom id.
    /// - parameter personEmail: The email address.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - returns: Membership
    public func create(roomId: String, personEmail: EmailAddress, isModerator: Bool = false) throws -> Membership {
        return try SyncUtil.getObject(authenticationStrategy, roomId, personEmail, isModerator, async: create)
    }
    
    /// Get details for a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - returns: Membership
    public func get(membershipId: String) throws -> Membership {
        return try SyncUtil.getObject(authenticationStrategy, membershipId, async: get)
    }
    
    /// Updates properties for a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - returns: Membership
    public func update(membershipId: String, isModerator: Bool) throws -> Membership {
        return try SyncUtil.getObject(authenticationStrategy, membershipId, isModerator, async: update)
    }
    
    /// Deletes a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - returns: Void
    public func delete(membershipId: String) throws {
        try SyncUtil.deleteObject(authenticationStrategy, membershipId, async: delete)
    }
}
