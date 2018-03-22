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
    
    let authenticator: Authenticator
    let config: SparkConfig
    init(authenticator: Authenticator, config: SparkConfig) {
        self.authenticator = authenticator
        self.config = config
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator,config).path("people")
    }
    
    /// Lists people in the authenticated user's organization.
    ///
    /// - parameter email: if not nil, only list people with this email address.
    /// - parameter displayName: if not nil, only list people whose name starts with this string.
    /// - parameter id: List people by ID. Accepts up to 85 person IDs separated by commas.
    /// - parameter orgId: List people in this organization. Only admin users of another organization (such as partners) may use this parameter.
    /// - parameter max: The maximum number of people in the response.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(email: EmailAddress? = nil, displayName: String? = nil, id: String? = nil,orgId: String? = nil,max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<[Person]>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .query(RequestParameter(["email": email?.toString(),
                                     "displayName": displayName,
                                     "id": id,
                                     "orgId":orgId,
                                     "max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Retrieves the details for a person by person id.
    ///
    /// - parameter personId: The identifier of the person.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(personId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Person>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .path(personId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Retrieves the details for the authenticated user.
    ///
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func getMe(queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Person>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .path("me")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Create people in the authenticated user's organization.
    /// Only admins are able to use this function
    ///
    /// - parameter email: Email address of the person.
    /// - parameter displayName: Full name of the person.
    /// - parameter firstName: firstName name of the person.
    /// - parameter lastName: lastName firstName name of the person.
    /// - parameter avatar: URL to the person's avatar in PNG format.
    /// - parameter orgId: ID of the organization to which this person belongs.
    /// - parameter roles: Roles of the person.
    /// - parameter licenses: Licenses allocated to the person.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Person
    /// - since: 1.4.0
    public func create(email: EmailAddress, displayName: String? = nil, firstName: String? = nil, lastName: String? = nil, avatar: String? = nil, orgId: String? = nil, roles: String? = nil, licenses: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Person>) -> Void) {
        let request = requestBuilder()
            .method(.post)
            .query(RequestParameter(["email": email.toString(),
                                     "displayName": displayName,
                                     "orgId":orgId,
                                     "firstName": firstName,
                                     "lastName" : lastName,
                                     "avatar" : avatar,
                                     "orgId" : orgId,
                                     "roles" : roles,
                                     "licenses": licenses,
                                     ]))
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Update people in the authenticated user's organization.
    /// Only admins are able to use this function
    ///
    /// - parameter personId: The identifier of the person.
    /// - parameter email: Email address of the person.
    /// - parameter displayName: Full name of the person.
    /// - parameter firstName: firstName name of the person.
    /// - parameter lastName: lastName firstName name of the person.
    /// - parameter avatar: URL to the person's avatar in PNG format.
    /// - parameter orgId: ID of the organization to which this person belongs.
    /// - parameter roles: Roles of the person.
    /// - parameter licenses: Licenses allocated to the person.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Person
    /// - since: 1.4.0
    public func update(personId: String, email: EmailAddress? = nil, displayName: String? = nil, firstName: String? = nil, lastName: String? = nil, avatar: String? = nil, orgId: String? = nil, roles: String? = nil, licenses: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Person>) -> Void) {
        let request = requestBuilder()
            .method(.put)
            .path(personId)
            .query(RequestParameter(["email": email?.toString(),
                                     "displayName": displayName,
                                     "orgId":orgId,
                                     "firstName": firstName,
                                     "lastName" : lastName,
                                     "avatar" : avatar,
                                     "orgId" : orgId,
                                     "roles" : roles,
                                     "licenses": licenses,
                                     ]))
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Delete the details of person by person id.
    /// Only admins are able to use this function
    ///
    /// - parameter personId: The identifier of the person.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func delete(personId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = requestBuilder()
            .method(.delete)
            .path(personId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
}
