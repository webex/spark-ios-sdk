//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

public enum Result<T> {
    case Success(T)
    case Failure(NSError)
}