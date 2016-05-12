//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Room HTTP client
public class RoomClient: CompletionHandlerType<Room> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("rooms")
    }

    /// List rooms. By default, lists rooms to which the authenticated user belongs.
    /// - Parameter max: Limit the maximum number of rooms in the response.
    /// - Parameter type: Available values: direct and group. direct returns all 1-to-1 rooms. group returns all group rooms. If not specified or values not matched, will return all room types.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func list(max max: Int? = nil, type: RoomType? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(HttpParameters(["max": max, "type": type?.rawValue]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Creates a room. The authenticated user is automatically added as a member of the room. See the Memberships API to learn how to add more people to the room.
    /// - Parameter title: A user-friendly name for the room.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func create(title title: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .body(HttpParameters(["title": title]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Shows details for a room by id. Specify the room id in the roomId parameter in the URI.
    /// - Parameter roomId: The room id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func get(roomId roomId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates details for a room by id. Specify the room id in the roomId parameter in the URI.
    /// - Parameter roomId: The room id.
    /// - Parameter title: A user-friendly name for the room.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func update(roomId roomId: String, title: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(HttpParameters(["title": title]))
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a room by id. Specify the room id in the roomId parameter in the URI.
    /// - Parameter roomId: The room id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func delete(roomId roomId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}