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

/// An iOS client wrapper of the Cisco Spark [Rooms REST API](https://developer.ciscospark.com/resource-rooms.html) .
///
/// - since: 1.2.0
public class RoomClient {
    
    /// Alias for closure to handle a service response along with a Room object.
    public typealias ObjectHandler = (ServiceResponse<Room>) -> Void
    
    /// Alias for closure to handle a service response along with a Room array.
    public typealias ArrayHandler = (ServiceResponse<[Room]>) -> Void
    
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).path("rooms")
    }
    
    /// Lists all rooms where the authenticated user belongs.
    ///
    /// - parameter teamId: If not nil, only list the rooms that are associated with the team by team id.
    /// - parameter max: The maximum number of rooms in the response.
    /// - parameter type: If not nil, only list the rooms of this type. Otherwise all rooms are listed.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(teamId: String? = nil , max: Int? = nil, type: RoomType? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
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
    /// - parameter teamId: If not nil, this room will be associated with the team by team id. Otherwise, this room is not associated with any team.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    /// - see: see MemebershipClient API
    public func create(title: String, teamId: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.post)
            .body(RequestParameter(["title": title, "teamId": teamId]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Retrieves the details for a room by id.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(roomId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates the details for a room by id.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter title: A user-friendly name for the room.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func update(roomId: String, title: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
            .body(RequestParameter(["title": title]))
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a room by id.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func delete(roomId: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
