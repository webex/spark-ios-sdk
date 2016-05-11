//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import Alamofire

public class CompletionHandlerType<T> {
    public typealias ObjectHandler = ServiceResponse<T> -> Void
    public typealias ArrayHandler = ServiceResponse<[T]> -> Void
    public typealias AnyObjectHandler = ServiceResponse<AnyObject> -> Void
}