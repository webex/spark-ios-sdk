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

/// TeamMembership HTTP client.
open class TeamMembershipClient {
    
    /// Alias for closure to handle a service response along with a TeamMembership object.
    public typealias ObjectHandler = (ServiceResponse<TeamMembership>) -> Void
    
    /// Alias for closure to handle a service response along with a TeamMembership array.
    public typealias ArrayHandler = (ServiceResponse<[TeamMembership]>) -> Void
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("team/memberships")
    }
    
    /// Lists all team memberships. By default, lists memberships for teams to which the authenticated user belongs.
    ///
    /// - parameter teamId: Limit results to a specific team, by ID.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func list(teamId: String, max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        let query = RequestParameter([
            "teamId": teamId,
            "max": max])
        
        let request = requestBuilder()
            .method(.get)
            .query(query)
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Add someone to a team by Person ID; optionally making them a moderator.
    ///
    /// - parameter teamId: The team ID.
    /// - parameter personId: The person ID.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func create(teamId: String, personId: String, isModerator: Bool = false, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let body = RequestParameter([
            "teamId": teamId,
            "personId": personId,
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Add someone to a teams by email address; optionally making them a moderator.
    ///
    /// - parameter teamId: The team ID.
    /// - parameter personEmail: The email address.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func create(teamId: String, personEmail: EmailAddress, isModerator: Bool = false, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let body = RequestParameter([
            "teamId": teamId,
            "personEmail": personEmail.toString(),
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Get details for a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func get(membershipId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates properties for a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - parameter isModerator: Set to true to make the person a team moderator.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func update(membershipId: String, isModerator: Bool, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
            .body(RequestParameter(["isModerator": isModerator]))
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a membership by ID.
    ///
    /// - parameter membershipId: The membership ID.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func delete(membershipId: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
