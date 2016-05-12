//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Completion handler when getting service reponse for a request.
public class CompletionHandlerType<T> {
    
    /// Alias for closure to handle a service response along with an object.
    public typealias ObjectHandler = ServiceResponse<T> -> Void
    
    /// Alias for closure to handle a service response along with an object array.
    public typealias ArrayHandler = ServiceResponse<[T]> -> Void
    
    /// Alias for closure to handle a service response along with an object in type of AnyObject.
    public typealias AnyObjectHandler = ServiceResponse<AnyObject> -> Void
}