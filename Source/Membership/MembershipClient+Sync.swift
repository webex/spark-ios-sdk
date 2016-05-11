//
//  MembershipClient+Sync.swift
//  Pods
//
//  Created by bxu3 on 5/6/16.
//
//

import Foundation
extension MembershipClient {
    public func list(roomId roomId: String? = nil, personId: String? = nil, personEmail: String? = nil, max: Int? = nil) throws -> [Membership] {
        return try SyncUtil.getArray(roomId, personId, personEmail, max, async: list)
    }
    
    public func createWithPersonId(roomId roomId: String, personId: String? = nil, isModerator: Bool? = nil) throws -> Membership {
        return try SyncUtil.getObject(roomId, personId, isModerator, async: createWithPersonId)
    }
    
    public func createWithPersonEmail(roomId roomId: String, personEmail: String? = nil, isModerator: Bool? = nil) throws -> Membership {
        return try SyncUtil.getObject(roomId, personEmail, isModerator, async: createWithPersonEmail)
    }
    
    public func get(membershipId membershipId: String) throws -> Membership {
        return try SyncUtil.getObject(membershipId, async: get)
    }
    
    public func update(membershipId membershipId: String, isModerator: Bool) throws -> Membership {
        return try SyncUtil.getObject(membershipId, isModerator, async: update)
    }
    
    public func delete(membershipId membershipId: String) throws {
        try SyncUtil.deleteObject(membershipId, async: delete)
    }
}