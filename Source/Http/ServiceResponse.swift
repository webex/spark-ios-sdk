//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Service response for a request.
public struct ServiceResponse<T> {
    
    /// Represents a response to an HTTP URL load.
    public let response: NSHTTPURLResponse?
    
    /// Result for a service request.
    public let result: Result<T>
    
    init(_ response: NSHTTPURLResponse?, _ result: Result<T>) {
        self.response = response
        self.result = result
    }
}