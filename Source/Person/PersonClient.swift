//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Person HTTP client
public class PersonClient: CompletionHandlerType<Person> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("people")
    }
    
    /// List people in your organization.
    /// - Parameter email: List people with this email address.
    /// - Parameter displayName: List people whose name starts with this string.
    /// - Parameter max: Limit the maximum number of people in the response.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func list(email email: String? = nil, displayName: String? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(HttpParameters(["email": email, "displayName": displayName, "max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Shows details for a person by id.
    /// - Parameter personId: A person id
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func get(personId personId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path(personId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Show the profile for the authenticated user.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func getMe(queue queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path("me")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
}
