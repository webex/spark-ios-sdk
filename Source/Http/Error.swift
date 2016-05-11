//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import SwiftyJSON

public struct Error {
    
    public static let Domain = "com.ciscospark.error"
    
    public enum Code: Int {
        case ServiceRequestFailed   = -7000
        case MediaAccessFailed      = -7001
    }
    
    public static func requestErrorWithData(data: NSData) -> NSError {
        var failureReason = "Service request failed without error message"
        if let errorMessage = JSON(data: data)["message"].string {
            failureReason = errorMessage
        }
        return Error.errorWithCode(Error.Code.ServiceRequestFailed, failureReason: failureReason)
    }
    
    public static func errorWithCode(code: Code, failureReason: String) -> NSError {
        return errorWithCode(code.rawValue, failureReason: failureReason)
    }
    
    public static func errorWithCode(code: Int, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Domain, code: code, userInfo: userInfo)
    }
}
