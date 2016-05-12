//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension PersonClient {
    
    /// List people in your organization.
    /// - parameter email: List people with this email address.
    /// - parameter displayName: List people whose name starts with this string.
    /// - parameter max: Limit the maximum number of people in the response.
    /// - returns: People array
    public func list(email email: String? = nil, displayName: String? = nil, max: Int? = nil) throws -> [Person] {
        return try SyncUtil.getArray(email, displayName, max, async: list)
    }
    
    /// Shows details for a person by id.
    /// - parameter personId: A person id
    /// - returns: Person
    public func get(personId personId: String) throws -> Person {
        return try SyncUtil.getObject(personId, async: get)
    }
    
    /// Show the profile for the authenticated user.
    /// - returns: Person
    public func getMe() throws -> Person {
        return try SyncUtil.getObject(getMe)
    }
}