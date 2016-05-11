//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

public struct ServiceResponse<T> {
    public let response: NSHTTPURLResponse?
    public let result: Result<T>
    
    public init(_ response: NSHTTPURLResponse?, _ result: Result<T>) {
        self.response = response
        self.result = result
    }
}