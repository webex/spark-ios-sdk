//
//  RoomClient+Sync.swift
//  Pods
//
//  Created by bxu3 on 5/6/16.
//
//

import Foundation
extension RoomClient {
    public func list(showSipAddress showSipAddress: Bool? = nil, max: Int? = nil) throws -> [Room] {
        return try SyncUtil.getArray(showSipAddress, max, async: list)
    }
    
    public func create(title title: String) throws -> Room {
        return try SyncUtil.getObject(title, async: create)
    }
    
    public func get(roomId roomId: String, showSipAddress: Bool? = nil) throws -> Room  {
        return try SyncUtil.getObject(roomId, showSipAddress, async: get)
    }
    
    public func update(roomId roomId: String, title: String) throws -> Room {
        return try SyncUtil.getObject(roomId, title, async: update)
    }
    
    public func delete(roomId roomId: String) throws {
        try SyncUtil.deleteObject(roomId, async: delete)
    }
}