// Copyright 2016-2017 Cisco Systems Inc
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

/// An iOS client wrapper of the Cisco Spark [People REST API](https://developer.ciscospark.com/resource-people.html) .
///
/// - since: 1.2.0
public class PersonClient {
    
    /// Alias for closure to handle a service response along with a Person object.
    public typealias ObjectHandler = (ServiceResponse<Person>) -> Void
    
    /// Alias for closure to handle a service response along with a Person array.
    public typealias ArrayHandler = (ServiceResponse<[Person]>) -> Void
    
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).path("people")
    }
    
    /// Lists people in the authenticated user's organization.
    ///
    /// - parameter email: if not nil, only list people with this email address.
    /// - parameter displayName: if not nil, only list people whose name starts with this string.
    /// - parameter max: The maximum number of people in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func list(email: EmailAddress? = nil, displayName: String? = nil, max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        let request = requestBuilder()
            .method(.get)
            .query(RequestParameter(["email": email?.toString(), "displayName": displayName, "max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Retrieves the details for a person by person id.
    ///
    /// - parameter personId: The identifier of the person.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func get(personId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
            .path(personId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Retrieves the details for the authenticated user.
    ///
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func getMe(queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
            .path("me")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
}
