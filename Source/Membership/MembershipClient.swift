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

/// Membership HTTP client.
public class MembershipClient: CompletionHandlerType<Membership> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("memberships")
    }
    
    /// Lists all room memberships. By default, lists memberships for rooms to which the authenticated user belongs.
    ///
    /// - parameter roomId: Limit results to a specific room by id.
    /// - parameter personId: Limit results to a specific person by id.
    /// - parameter personEmail: Limit results to a specific person by email address.
    /// - parameter max: Limit the maximum number of items in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func list(roomId roomId: String? = nil, personId: String? = nil, personEmail: EmailAddress? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        
        let query = RequestParameter([
            "roomId": roomId,
            "personId": personId,
            "personEmail": personEmail?.toString(),
            "max": max])
        
        let request = requestBuilder()
            .method(.GET)
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
    public func create(roomId roomId: String, personId: String, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
            "roomId": roomId,
            "personId": personId,
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.POST)
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
    public func create(roomId roomId: String, personEmail: EmailAddress, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
            "roomId": roomId,
            "personEmail": personEmail.toString(),
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.POST)
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
    public func get(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
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
    public func update(membershipId membershipId: String, isModerator: Bool, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
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
    public func delete(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}