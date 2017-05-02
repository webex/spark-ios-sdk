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

/// An iOS client wrapper of the Cisco Spark [Room Memberships REST API](https://developer.ciscospark.com/resource-memberships.html) .
///
/// - since: 1.2.0
public class MembershipClient {
    
    /// Alias for closure to handle a service response along with a Membership object.
    ///
    /// - since: 1.2.0
    public typealias ObjectHandler = (ServiceResponse<Membership>) -> Void
    
    /// Alias for closure to handle a service response along with a Membership array.
    ///
    /// - since: 1.2.0
    public typealias ArrayHandler = (ServiceResponse<[Membership]>) -> Void
    
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).path("memberships")
    }

    /// Lists all room memberships where the authenticated user belongs.
    ///
    /// - parameter max: The maximum number of items in the response.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        list(roomId: nil, personId: nil, personEmail: nil, max: max, queue: queue, completionHandler: completionHandler)
    }
    
    /// Lists all memberships in the given room by room Id.
    ///
    /// - parameter roomId: The identifier of the room where the membership belongs.
    /// - parameter max: The maximum number of memberships in the response.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(roomId: String, max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        list(roomId: roomId, personId: nil, personEmail: nil, max: max, queue: queue, completionHandler: completionHandler)
    }
    
    /// Lists any room memberships for the given room (by room id) and person (by person id).
    ///
    /// - parameter roomId: The identifier of the room where the memberships belong.
    /// - parameter personId: The identifier of the person who has the memberships.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(roomId: String, personId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        list(roomId: roomId, personId: personId, personEmail: nil, max: nil, queue: queue, completionHandler: completionHandler)
    }
    
    /// Lists any room memberships for the given room (by room id) and person (by email address).
    ///
    /// - parameter roomId: The identifier of the room where the memberships belong.
    /// - parameter personEmail: The email address of the person who has the memberships.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(roomId: String, personEmail: EmailAddress, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        list(roomId: roomId, personId: nil, personEmail: personEmail, max: nil, queue: queue, completionHandler: completionHandler)
    }
    
    private func list(roomId: String?, personId: String?, personEmail: EmailAddress?, max: Int?, queue: DispatchQueue?, completionHandler: @escaping ArrayHandler) {
        
        let query = RequestParameter([
            "roomId": roomId,
            "personId": personId,
            "personEmail": personEmail?.toString(),
            "max": max])
        
        let request = requestBuilder()
            .method(.get)
            .query(query)
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Adds a person to a room by person id; optionally making the person a moderator.
    ///
    /// - parameter roomId: The identifier of the room where the person is to be added.
    /// - parameter personId: The identifier of the person to be added.
    /// - parameter isModerator: If true, make the person a moderator of the room. The default is false.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func create(roomId: String, personId: String, isModerator: Bool = false, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let body = RequestParameter([
            "roomId": roomId,
            "personId": personId,
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Adds a person to a room by email address; optionally making the person a moderator.
    ///
    /// - parameter roomId: The identifier of the room where the person is to be added.
    /// - parameter personEmail: The email address of the person to be added.
    /// - parameter isModerator: If true, make the person a moderator of the room. The default is false.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func create(roomId: String, personEmail: EmailAddress, isModerator: Bool = false, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let body = RequestParameter([
            "roomId": roomId,
            "personEmail": personEmail.toString(),
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Retrieves the details for a membership by membership id.
    ///
    /// - parameter membershipId: The identifier of the membership.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(membershipId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates the properties of a membership by membership id.
    ///
    /// - parameter membershipId: The identifier of the membership.
    /// - parameter isModerator: If true, make the person a moderator of the room in this membership. The default is false.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func update(membershipId: String, isModerator: Bool, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
            .body(RequestParameter(["isModerator": isModerator]))
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a membership by membership id. It removes the person from the room where the membership belongs.
    ///
    /// - parameter membershipId: The identifier of the membership.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func delete(membershipId: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
