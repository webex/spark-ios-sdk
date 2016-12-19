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

/// Webhook HTTP client.
public class WebhookClient {
    
    /// Alias for closure to handle a service response along with a Webhook object.
    public typealias ObjectHandler = (ServiceResponse<Webhook>) -> Void
    
    /// Alias for closure to handle a service response along with a Webhook array.
    public typealias ArrayHandler = (ServiceResponse<[Webhook]>) -> Void
    
    let authenticationStrategy: AuthenticationStrategy
    
    init(authenticationStrategy: AuthenticationStrategy) {
        self.authenticationStrategy = authenticationStrategy
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticationStrategy).path("webhooks")
    }
    
    /// Lists all webhooks.
    ///
    /// - parameter max: Limit the maximum number of webhooks in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func list(max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        let request = requestBuilder()
            .method(.get)
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
    open func create(name: String, targetUrl: String, resource: String, event: String, filter: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let body = RequestParameter([
            "name": name,
            "targetUrl": targetUrl,
            "resource": resource,
            "event": event,
            "filter": filter])
        
        let request = requestBuilder()
            .method(.post)
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
    open func get(webhookId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
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
    open func update(webhookId: String, name: String, targetUrl: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
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
    open func delete(webhookId: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
