// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Person HTTP client
public class PersonClient: CompletionHandlerType<Person> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("people")
    }
    
    /// List people in your organization.
    ///
    /// - parameter email: List people with this email address.
    /// - parameter displayName: List people whose name starts with this string.
    /// - parameter max: Limit the maximum number of people in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func list(email email: EmailAddress? = nil, displayName: String? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(RequestParameter(["email": email?.toString(), "displayName": displayName, "max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Shows details for a person by id.
    ///
    /// - parameter personId: A person id
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func get(personId personId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path(personId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Show the profile for the authenticated user.
    ///
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    public func getMe(queue queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path("me")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
}
