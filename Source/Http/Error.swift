//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import SwiftyJSON

/// Errors when getting service reponse for a request.
struct Error {
    
    /// Domain of this error.
    static let Domain = "com.ciscospark.error"
    
    /// Error code.
    enum Code: Int {
        case ServiceRequestFailed   = -7000
    }
    
    /// Converts the error data to NSError
    static func requestErrorWithData(data: NSData) -> NSError {
        var failureReason = "Service request failed without error message"
        if let errorMessage = JSON(data: data)["message"].string {
            failureReason = errorMessage
        }
        return Error.errorWithCode(Error.Code.ServiceRequestFailed, failureReason: failureReason)
    }
    
    private static func errorWithCode(code: Code, failureReason: String) -> NSError {
        return errorWithCode(code.rawValue, failureReason: failureReason)
    }
    
    private static func errorWithCode(code: Int, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Domain, code: code, userInfo: userInfo)
    }
}
