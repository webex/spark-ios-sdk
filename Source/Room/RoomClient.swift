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

/// Room HTTP client
public class RoomClient: CompletionHandlerType<Room> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("rooms")
    }

    /// List rooms. By default, lists rooms to which the authenticated user belongs.
    ///
    /// - parameter teamId: Limit the rooms to those associated with a team, by ID.
    /// - parameter max: Limit the maximum number of rooms in the response.
    /// - parameter type: Available values: direct and group. direct returns all 1-to-1 rooms. group returns all group rooms. If not specified or values not matched, will return all room types.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func list(teamId teamId: String? = nil , max: Int? = nil, type: RoomType? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(RequestParameter(["teamId": teamId, "max": max, "type": type?.rawValue]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Creates a room. The authenticated user is automatically added as a member of the room. See the Memberships API to learn how to add more people to the room.
    ///
    /// - parameter title: A user-friendly name for the room.
    /// - parameter teamId: The ID for the team with which this room is associated.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func create(title title: String, teamId: String? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .body(RequestParameter(["title": title, "teamId": teamId]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Shows details for a room by id. Specify the room id in the roomId parameter in the URI.
    ///
    /// - parameter roomId: The room id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func get(roomId roomId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates details for a room by id. Specify the room id in the roomId parameter in the URI.
    ///
    /// - parameter roomId: The room id.
    /// - parameter title: A user-friendly name for the room.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func update(roomId roomId: String, title: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(RequestParameter(["title": title]))
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a room by id. Specify the room id in the roomId parameter in the URI.
    ///
    /// - parameter roomId: The room id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func delete(roomId roomId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}