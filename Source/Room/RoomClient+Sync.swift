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

extension RoomClient {
    
    /// List rooms. By default, lists rooms to which the authenticated user belongs.
    ///
    /// - parameter max: Limit the maximum number of rooms in the response.
    /// - parameter type: Available values: direct and group. direct returns all 1-to-1 rooms. group returns all group rooms. If not specified or values not matched, will return all room types.
    /// - returns: Rooms array
    public func list(max max: Int? = nil, type: RoomType? = nil) throws -> [Room] {
        return try SyncUtil.getArray(max, type, async: list)
    }
    
    /// Creates a room. The authenticated user is automatically added as a member of the room. See the Memberships API to learn how to add more people to the room.
    ///
    /// - parameter title: A user-friendly name for the room.
    /// - returns: Room
    public func create(title title: String) throws -> Room {
        return try SyncUtil.getObject(title, async: create)
    }
    
    /// Shows details for a room by id. Specify the room id in the roomId parameter in the URI.
    ///
    /// - parameter roomId: The room id.
    /// - returns: Room
    public func get(roomId roomId: String) throws -> Room  {
        return try SyncUtil.getObject(roomId, async: get)
    }
    
    /// Updates details for a room by id. Specify the room id in the roomId parameter in the URI.
    ///
    /// - parameter roomId: The room id.
    /// - parameter title: A user-friendly name for the room.
    /// - returns: Room
    public func update(roomId roomId: String, title: String) throws -> Room {
        return try SyncUtil.getObject(roomId, title, async: update)
    }
    
    /// Deletes a room by id. Specify the room id in the roomId parameter in the URI.
    ///
    /// - parameter roomId: The room id.
    /// - returns: Void
    public func delete(roomId roomId: String) throws {
        try SyncUtil.deleteObject(roomId, async: delete)
    }
}