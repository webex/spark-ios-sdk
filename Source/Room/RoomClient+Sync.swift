//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension RoomClient {
    
    /// List rooms. By default, lists rooms to which the authenticated user belongs.
    /// - Parameter max: Limit the maximum number of rooms in the response.
    /// - Parameter type: Available values: direct and group. direct returns all 1-to-1 rooms. group returns all group rooms. If not specified or values not matched, will return all room types.
    /// - Returns: Rooms array
    public func list(max max: Int? = nil, type: RoomType? = nil) throws -> [Room] {
        return try SyncUtil.getArray(max, type, async: list)
    }
    
    /// Creates a room. The authenticated user is automatically added as a member of the room. See the Memberships API to learn how to add more people to the room.
    /// - Parameter title: A user-friendly name for the room.
    /// - Returns: Room
    public func create(title title: String) throws -> Room {
        return try SyncUtil.getObject(title, async: create)
    }
    
    /// Shows details for a room by id. Specify the room id in the roomId parameter in the URI.
    /// - Parameter roomId: The room id.
    /// - Returns: Room
    public func get(roomId roomId: String) throws -> Room  {
        return try SyncUtil.getObject(roomId, async: get)
    }
    
    /// Updates details for a room by id. Specify the room id in the roomId parameter in the URI.
    /// - Parameter roomId: The room id.
    /// - Parameter title: A user-friendly name for the room.
    /// - Returns: Room
    public func update(roomId roomId: String, title: String) throws -> Room {
        return try SyncUtil.getObject(roomId, title, async: update)
    }
    
    /// Deletes a room by id. Specify the room id in the roomId parameter in the URI.
    /// - Parameter roomId: The room id.
    /// - Returns: Void
    public func delete(roomId roomId: String) throws {
        try SyncUtil.deleteObject(roomId, async: delete)
    }
}