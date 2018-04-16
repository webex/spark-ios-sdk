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

/// An iOS client wrapper of the Cisco Spark [Webhooks REST API](https://developer.ciscospark.com/resource-webhooks.html) .
///
/// - since: 1.2.0
public class WebhookClient {
    
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).path("webhooks")
    }
    
    /// Lists all webhooks of the authenticated user.
    ///
    /// - parameter max: The maximum number of webhooks in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<[Webhook]>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .query(RequestParameter(["max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Posts a webhook for the authenticated user.
    ///
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - parameter resource: The resource type for the webhook.
    /// - parameter event: The event type for the webhook.
    /// - parameter filter: The filter that defines the webhook scope.
    /// - parameter secet: Secret use to generate payload signiture
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter secet: Secret use to generate payload signiture
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func create(name: String, targetUrl: String, resource: String, event: String, filter: String? = nil, secret: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Webhook>) -> Void) {
        let body = RequestParameter([
            "name": name,
            "targetUrl": targetUrl,
            "resource": resource,
            "event": event,
            "filter": filter,
            "secret": secret])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }

    /// Retrieves the details for a webhook by id.
    ///
    /// - parameter webhookId: The identifier of  the webhook.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(webhookId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Webhook>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Updates a webhook by id.
    ///
    /// - parameter webhookId: The identifier of  the webhook.
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - parameter status: The status of the webhook. Use "active" to reactivate a disabled webhook.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func update(webhookId: String, name: String, targetUrl: String,  secret: String? = nil, status: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Webhook>) -> Void) {
        let request = requestBuilder()
            .method(.put)
            .body(RequestParameter(["name": name, "targetUrl": targetUrl, "secret" : secret, "status" : status ]))
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a webhook by id.
    ///
    /// - parameter webhookId: The identifier of  the webhook.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - parameter webhookId: The identifier of  the webhook.
    /// - since: 1.2.0
    public func delete(webhookId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = requestBuilder()
            .method(.delete)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
