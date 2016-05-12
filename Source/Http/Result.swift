//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Service request results.
public enum Result<T> {
    
    /// Result for Success, with the expected object.
    case Success(T)
    
    /// Result for Failure, with the error message.
    case Failure(NSError)
}