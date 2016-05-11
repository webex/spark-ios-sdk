//
//  MessageClient+Sync.swift
//  Pods
//
//  Created by bxu3 on 5/6/16.
//
//

import Foundation

extension MessageClient {
    public func list(roomId roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil) throws -> [Message] {
        return try SyncUtil.getArray(roomId, before, beforeMessage, max, async: list)
    }
    
    public func create(roomId roomId: String? = nil, text: String? = nil, files: String? = nil, toPersonId: String? = nil, toPersonEmail: String? = nil) throws -> Message {
        return try SyncUtil.getObject(roomId, text, files, toPersonId, toPersonEmail, async: create)
    }
    
    public func get(messageId messageId: String) throws -> Message {
        return try SyncUtil.getObject(messageId, async: get)
    }
    
    public func delete(messageId messageId: String) throws {
        try SyncUtil.deleteObject(messageId, async: delete)
    }
}
