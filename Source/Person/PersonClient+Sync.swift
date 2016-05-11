//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension PersonClient {
    
    /// List people in your organization.
    /// - Parameter email: List people with this email address.
    /// - Parameter displayName: List people whose name starts with this string.
    /// - Parameter max: Limit the maximum number of people in the response.
    /// - Returns: People array
    public func list(email email: String? = nil, displayName: String? = nil, max: Int? = nil) throws -> [Person] {
        return try SyncUtil.getArray(email, displayName, max, async: list)
    }
    
    /// Shows details for a person by id.
    /// - Parameter personId: A person id
    /// - Returns: Person
    public func get(personId personId: String) throws -> Person {
        return try SyncUtil.getObject(personId, async: get)
    }
    
    /// Show the profile for the authenticated user.
    /// - Returns: Person
    public func getMe() throws -> Person {
        return try SyncUtil.getObject(getMe)
    }
}