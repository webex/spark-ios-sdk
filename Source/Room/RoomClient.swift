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

/// Room HTTP client
open class RoomClient {
    
    /// Alias for closure to handle a service response along with a Room object.
    public typealias ObjectHandler = (ServiceResponse<Room>) -> Void
    
    /// Alias for closure to handle a service response along with a Room array.
    public typealias ArrayHandler = (ServiceResponse<[Room]>) -> Void
    
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
    open func list(teamId: String? = nil , max: Int? = nil, type: RoomType? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        let request = requestBuilder()
            .method(.get)
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
    open func create(title: String, teamId: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.post)
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
    open func get(roomId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
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
    open func update(roomId: String, title: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
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
    open func delete(roomId: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
