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
extension PersonClient {
    
    /// List people in your organization.
    ///
    /// - parameter email: List people with this email address.
    /// - parameter displayName: List people whose name starts with this string.
    /// - parameter max: Limit the maximum number of people in the response.
    /// - returns: People array
    public func list(email: EmailAddress? = nil, displayName: String? = nil, max: Int? = nil) throws -> [Person] {
        return try SyncUtil.getArray(authenticationStrategy, email, displayName, max, async: list)
    }
    
    /// Shows details for a person by id.
    ///
    /// - parameter personId: A person id
    /// - returns: Person
    public func get(personId: String) throws -> Person {
        return try SyncUtil.getObject(authenticationStrategy, personId, async: get)
    }
    
    /// Show the profile for the authenticated user.
    ///
    /// - returns: Person
    public func getMe() throws -> Person {
        return try SyncUtil.getObject(authenticationStrategy, getMe)
    }
}
