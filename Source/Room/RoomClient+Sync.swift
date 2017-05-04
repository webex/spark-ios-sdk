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
extension RoomClient {
    
    /// List rooms. By default, lists rooms to which the authenticated user belongs.
    ///
    /// - parameter teamId: Limit the rooms to those associated with a team, by ID.
    /// - parameter max: Limit the maximum number of rooms in the response.
    /// - parameter type: Available values: direct and group. direct returns all 1-to-1 rooms. group returns all group rooms. If not specified or values not matched, will return all room types.
    /// - returns: Room array
    public func list(teamId: String? = nil, max: Int? = nil, type: RoomType? = nil) throws -> [Room] {
        return try SyncUtil.getArray(authenticator, teamId, max, type, async: list)
    }
    
    /// Creates a room. The authenticated user is automatically added as a member of the room. See the Memberships API to learn how to add more people to the room.
    ///
    /// - parameter title: A user-friendly name for the room.
    /// - parameter teamId: The ID for the team with which this room is associated.
    /// - returns: Room
    public func create(title: String, teamId: String? = nil) throws -> Room {
        return try SyncUtil.getObject(authenticator, title, teamId, async: create)
    }
    
    /// Shows details for a room by id.
    ///
    /// - parameter roomId: The room id.
    /// - returns: Room
    public func get(roomId: String) throws -> Room  {
        return try SyncUtil.getObject(authenticator, roomId, async: get)
    }
    
    /// Updates details for a room by id.
    ///
    /// - parameter roomId: The room id.
    /// - parameter title: A user-friendly name for the room.
    /// - returns: Room
    public func update(roomId: String, title: String) throws -> Room {
        return try SyncUtil.getObject(authenticator, roomId, title, async: update)
    }
    
    /// Deletes a room by id.
    ///
    /// - parameter roomId: The room id.
    /// - returns: Void
    public func delete(roomId: String) throws {
        try SyncUtil.deleteObject(authenticator, roomId, async: delete)
    }
}
