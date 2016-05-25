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
