//
//  WebHookClient+Sync.swift
//  Pods
//
//  Created by bxu3 on 5/6/16.
//
//

import Foundation
extension WebhookClient {
    public func list(max max: Int? = nil) throws -> [Webhook] {
        return try SyncUtil.getArray(max, async: list)
    }
    
    public func create(name name: String, targetUrl: String, resource: String, event: String, filter: String) throws -> Webhook {
        return try SyncUtil.getObject(name, targetUrl, resource, event, filter, async: create)
    }
    
    public func get(webhookId webhookId: String) throws -> Webhook {
        return try SyncUtil.getObject(webhookId, async: get)
    }
    
    public func update(webhookId webhookId: String, name: String, targetUrl: String) throws -> Webhook {
        return try SyncUtil.getObject(webhookId, name, targetUrl, async: update)
    }
    
    public func delete(webhookId webhookId: String) throws {
        try SyncUtil.deleteObject(webhookId, async: delete)
    }

}