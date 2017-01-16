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

@available(*, deprecated, message: "Network calls should be made using the equivalent asynchronous calls on the client")
extension WebhookClient {
    
    /// Lists all webhooks
    ///
    /// - parameter max: Limit the maximum number of webhooks in the response.
    /// - returns: Webhooks array
    public func list(max: Int? = nil) throws -> [Webhook] {
		return try SyncUtil.getArray(authenticationStrategy, max, async: list)
    }
    
    /// Posts a webhook.
    ///
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - parameter resource: The resource type for the webhook.
    /// - parameter event: The event type for the webhook.
    /// - parameter filter: The filter that defines the webhook scope.
    /// - returns: Webhook
    public func create(name: String, targetUrl: String, resource: String, event: String, filter: String) throws -> Webhook {
		return try SyncUtil.getObject(authenticationStrategy, name, targetUrl, resource, event, filter, async: create)
    }
    
    /// Shows details for a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - returns: Webhook
    public func get(webhookId: String) throws -> Webhook {
        return try SyncUtil.getObject(authenticationStrategy, webhookId, async: get)
    }
    
    /// Updates a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - returns: Webhook
    public func update(webhookId: String, name: String, targetUrl: String) throws -> Webhook {
        return try SyncUtil.getObject(authenticationStrategy, webhookId, name, targetUrl, async: update)
    }
    
    /// Deletes a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - returns: Void
    public func delete(webhookId: String) throws {
        try SyncUtil.deleteObject(authenticationStrategy, webhookId, async: delete)
    }

}
