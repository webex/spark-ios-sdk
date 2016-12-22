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

/// Membership HTTP client.
public class MembershipClient {
    
    /// Alias for closure to handle a service response along with a Membership object.
    public typealias ObjectHandler = (ServiceResponse<Membership>) -> Void
    
    /// Alias for closure to handle a service response along with a Membership array.
    public typealias ArrayHandler = (ServiceResponse<[Membership]>) -> Void
    
    let authenticationStrategy: AuthenticationStrategy
    
    init(authenticationStrategy: AuthenticationStrategy) {
        self.authenticationStrategy = authenticationStrategy
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticationStrategy).path("memberships")
    }
    
    /// Lists all room memberships. By default, lists memberships for rooms to which the authenticated user belongs.
    ///
    /// - parameter roomId: Limit results to a specific room by id.
    /// - parameter personId: Limit results to a specific person by id.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func list(roomId: String? = nil, personId: String? = nil, max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        list(roomId: roomId, personId: personId, personEmail: nil, max: max, queue: queue, completionHandler: completionHandler)
    }
    
    /// Lists all room memberships. By default, lists memberships for rooms to which the authenticated user belongs.
    ///
    /// - parameter roomId: Limit results to a specific room by id.
    /// - parameter personEmail: Limit results to a specific person by email address.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func list(roomId: String? = nil, personEmail: EmailAddress?, max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        list(roomId: roomId, personId: nil, personEmail: personEmail, max: max, queue: queue, completionHandler: completionHandler)
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
    
    /// Add someone to a room by person id; optionally making them a moderator.
    ///
    /// - parameter roomId: The rooom id.
    /// - parameter personId: The person id.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
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
    
    /// Add someone to a room by email address; optionally making them a moderator.
    ///
    /// - parameter roomId: The rooom id.
    /// - parameter personEmail: The email address.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
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
    
    /// Get details for a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func get(membershipId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates properties for a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - parameter isModerator: Set to true to make the person a room moderator.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func update(membershipId: String, isModerator: Bool, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
            .body(RequestParameter(["isModerator": isModerator]))
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a membership by id.
    ///
    /// - parameter membershipId: The membership id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func delete(membershipId: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
