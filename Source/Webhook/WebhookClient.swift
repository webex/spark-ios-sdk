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

/// Webhook HTTP client.
public class WebhookClient: CompletionHandlerType<Webhook> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("webhooks")
    }
    
    /// Lists all webhooks.
    ///
    /// - parameter max: Limit the maximum number of webhooks in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func list(max max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(RequestParameter(["max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Posts a webhook.
    ///
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - parameter resource: The resource type for the webhook.
    /// - parameter event: The event type for the webhook.
    /// - parameter filter: The filter that defines the webhook scope.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func create(name name: String, targetUrl: String, resource: String, event: String, filter: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
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
    ///
    /// - parameter webhookId: A webhook id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func get(webhookId webhookId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func update(webhookId webhookId: String, name: String, targetUrl: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(RequestParameter(["name": name, "targetUrl": targetUrl]))
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func delete(webhookId webhookId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}