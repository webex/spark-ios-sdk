//
//  Person+Sync.swift
//  Pods
//
//  Created by Bin Xu on 5/5/16.
//
//

import Foundation

extension PersonClient {
    public func list(email email: String? = nil, displayName: String? = nil, max: Int? = nil) throws -> [Person] {
        return try SyncUtil.getArray(email, displayName, max, async: list)
    }
    
    public func get(personId personId: String) throws -> Person {
        return try SyncUtil.getObject(personId, async: get)
    }
    
    public func getMe() throws -> Person {
        return try SyncUtil.getObject(getMe)
    }
}