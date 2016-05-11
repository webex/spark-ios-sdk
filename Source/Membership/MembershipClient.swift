//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Membership HTTP client.
public class MembershipClient: CompletionHandlerType<Membership> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("memberships")
    }
    
    /// Lists all room memberships. By default, lists memberships for rooms to which the authenticated user belongs.
    /// - Parameter roomId: Limit results to a specific room by id.
    /// - Parameter personId: Limit results to a specific person by id.
    /// - Parameter personEmail: Limit results to a specific person by email address.
    /// - Parameter max: Limit the maximum number of items in the response.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func list(roomId roomId: String? = nil, personId: String? = nil, personEmail: String? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        
        let query = HttpParameters([
            "roomId": roomId,
            "personId": personId,
            "personEmail": personEmail,
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
    /// - Parameter roomId: The rooom id.
    /// - Parameter personId: The person id.
    /// - Parameter isModerator: Set to true to make the person a room moderator.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func createWithPersonId(roomId roomId: String, personId: String? = nil, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
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
    /// - Parameter roomId: The rooom id.
    /// - Parameter personEmail: The email address.
    /// - Parameter isModerator: Set to true to make the person a room moderator.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func createWithPersonEmail(roomId roomId: String, personEmail: String? = nil, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
            "roomId": roomId,
            "personEmail": personEmail,
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.POST)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Get details for a membership by id.
    /// - Parameter membershipId: The membership id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func get(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates properties for a membership by id.
    /// - Parameter membershipId: The membership id.
    /// - Parameter isModerator: Set to true to make the person a room moderator.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func update(membershipId membershipId: String, isModerator: Bool, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(HttpParameters(["isModerator": isModerator]))
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a membership by id.
    /// - Parameter membershipId: The membership id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func delete(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}