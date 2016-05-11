//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension WebhookClient {
    
    /// Lists all webhooks
    /// - Parameter max: Limit the maximum number of webhooks in the response.
    /// - Returns: Webhooks array
    public func list(max max: Int? = nil) throws -> [Webhook] {
        return try SyncUtil.getArray(max, async: list)
    }
    
    /// Posts a webhook.
    /// - Parameter name: A user-friendly name for this webhook.
    /// - Parameter targetUrl: The URL that receives POST requests for each event.
    /// - Parameter resource: The resource type for the webhook.
    /// - Parameter event: The event type for the webhook.
    /// - Parameter filter: The filter that defines the webhook scope.
    /// - Returns: Webhook
    public func create(name name: String, targetUrl: String, resource: String, event: String, filter: String) throws -> Webhook {
        return try SyncUtil.getObject(name, targetUrl, resource, event, filter, async: create)
    }
    
    /// Shows details for a webhook by id.
    /// - Parameter webhookId: A webhook id.
    /// - Returns: Webhook
    public func get(webhookId webhookId: String) throws -> Webhook {
        return try SyncUtil.getObject(webhookId, async: get)
    }
    
    /// Updates a webhook by id.
    /// - Parameter webhookId: A webhook id.
    /// - Parameter name: A user-friendly name for this webhook.
    /// - Parameter targetUrl: The URL that receives POST requests for each event.
    /// - Returns: Webhook
    public func update(webhookId webhookId: String, name: String, targetUrl: String) throws -> Webhook {
        return try SyncUtil.getObject(webhookId, name, targetUrl, async: update)
    }
    
    /// Deletes a webhook by id.
    /// - Parameter webhookId: A webhook id.
    /// - Returns: Void
    public func delete(webhookId webhookId: String) throws {
        try SyncUtil.deleteObject(webhookId, async: delete)
    }

}