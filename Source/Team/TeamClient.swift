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

/// An iOS client wrapper of the Cisco Spark [Teams REST API](https://developer.ciscospark.com/resource-teams.html) .
///
/// - since: 1.2.0
public class TeamClient {
    
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }

    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).path("teams")
    }
    
    /// Lists teams to which the authenticated user belongs.
    ///
    /// - parameter max: The maximum number of teams in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<[Team]>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .query(RequestParameter(["max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Creates a team. The authenticated user is automatically added as a member of the team. 
    /// See the Team Memberships API to learn how to add more people to the team.
    ///
    /// - parameter title: A user-friendly name for the team.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    /// - see: see TeamMemebershipClient API
    public func create(name: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Team>) -> Void) {
        let request = requestBuilder()
            .method(.post)
            .body(RequestParameter(["name": name]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    
    /// Retrieves the details for a team by id.
    ///
    /// - parameter teamId: The identifier of the team.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(teamId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Team>) -> Void){
        let request = requestBuilder()
            .method(.get)
            .path(teamId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates the details for a team by id.
    ///
    /// - parameter teamId: The team id.
    /// - parameter name: A user-friendly name for the team.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func update(teamId: String, name: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Team>) -> Void) {
        let request = requestBuilder()
            .method(.put)
            .body(RequestParameter(["name": name]))
            .path(teamId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a team by id.
    ///
    /// - parameter teamId: The team id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func delete(teamId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = requestBuilder()
            .method(.delete)
            .path(teamId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
