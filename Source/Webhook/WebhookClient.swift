//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Webhook HTTP client
public class WebhookClient: CompletionHandlerType<Webhook> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("webhooks")
    }
    
    /// Lists all webhooks
    /// - Parameter max: Limit the maximum number of webhooks in the response.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func list(max max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(HttpParameters(["max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Posts a webhook.
    /// - Parameter name: A user-friendly name for this webhook.
    /// - Parameter targetUrl: The URL that receives POST requests for each event.
    /// - Parameter resource: The resource type for the webhook.
    /// - Parameter event: The event type for the webhook.
    /// - Parameter filter: The filter that defines the webhook scope.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func create(name name: String, targetUrl: String, resource: String, event: String, filter: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
            "name": name,
            "targetUrl": targetUrl,
            "resource": resource,
            "event": event,
            "filter": filter])
        
        let request = requestBuilder()
            .method(.POST)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Shows details for a webhook by id.
    /// - Parameter webhookId: A webhook id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func get(webhookId webhookId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates a webhook by id.
    /// - Parameter webhookId: A webhook id.
    /// - Parameter name: A user-friendly name for this webhook.
    /// - Parameter targetUrl: The URL that receives POST requests for each event.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func update(webhookId webhookId: String, name: String, targetUrl: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(HttpParameters(["name": name, "targetUrl": targetUrl]))
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a webhook by id.
    /// - Parameter webhookId: A webhook id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func delete(webhookId webhookId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}