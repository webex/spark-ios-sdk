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

/// TeamMembership HTTP client.
public class TeamMembershipClient: CompletionHandlerType<TeamMembership> {
    
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
    public func list(teamId teamId: String, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let query = RequestParameter([
            "teamId": teamId,
            "max": max])
        
        let request = requestBuilder()
            .method(.GET)
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
    public func create(teamId teamId: String, personId: String, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
            "teamId": teamId,
            "personId": personId,
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.POST)
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
    public func create(teamId teamId: String, personEmail: EmailAddress, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
            "teamId": teamId,
            "personEmail": personEmail.toString(),
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.POST)
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
    public func get(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
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
    public func update(membershipId membershipId: String, isModerator: Bool, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
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
    public func delete(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
