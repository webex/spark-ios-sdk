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

extension WebhookClient {
    
    /// Lists all webhooks
    ///
    /// - parameter max: Limit the maximum number of webhooks in the response.
    /// - returns: Webhooks array
    public func list(max max: Int? = nil) throws -> [Webhook] {
        return try SyncUtil.getArray(max, async: list)
    }
    
    /// Posts a webhook.
    ///
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - parameter resource: The resource type for the webhook.
    /// - parameter event: The event type for the webhook.
    /// - parameter filter: The filter that defines the webhook scope.
    /// - returns: Webhook
    public func create(name name: String, targetUrl: String, resource: String, event: String, filter: String) throws -> Webhook {
        return try SyncUtil.getObject(name, targetUrl, resource, event, filter, async: create)
    }
    
    /// Shows details for a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - returns: Webhook
    public func get(webhookId webhookId: String) throws -> Webhook {
        return try SyncUtil.getObject(webhookId, async: get)
    }
    
    /// Updates a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - parameter name: A user-friendly name for this webhook.
    /// - parameter targetUrl: The URL that receives POST requests for each event.
    /// - returns: Webhook
    public func update(webhookId webhookId: String, name: String, targetUrl: String) throws -> Webhook {
        return try SyncUtil.getObject(webhookId, name, targetUrl, async: update)
    }
    
    /// Deletes a webhook by id.
    ///
    /// - parameter webhookId: A webhook id.
    /// - returns: Void
    public func delete(webhookId webhookId: String) throws {
        try SyncUtil.deleteObject(webhookId, async: delete)
    }

}