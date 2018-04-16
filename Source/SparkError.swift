// Copyright 2016-2017 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

/// The enumeration of error types in Cisco Spark iOS SDK.
///
/// - since: 1.2.0
public enum SparkError: Error {
    /// A service request to Cisco Spark cloud has failed.
    case serviceFailed(code: Int, reason: String)
    /// The *Phone* has not been registered.
    case unregistered
    /// The media requires H.264 codec.
    case requireH264
    /// The DTMF is invalid.
    case invalidDTMF
    /// The DTMF is unsupported.
    case unsupportedDTMF
    /// The service request is illegal.
    case illegalOperation(reason: String)
    /// The service is in an illegal status.
    case illegalStatus(reason: String)
    /// The authentication is failed.
    /// - since 1.4.0
    case noAuth
}

extension SparkError: LocalizedError {
    /// Details of the error.
    public var errorDescription: String? {
        switch self {
        case .serviceFailed(let code, let reason):
            return "The service returned an error \(code), \(reason)"
        case .unregistered:
            return "unregistered"
        case .requireH264:
            return "requireH264"
        case .invalidDTMF:
            return "invalidDTMF"
        case .unsupportedDTMF:
            return "unsupportedDTMF"
        case .illegalOperation(let reason):
            return reason
        case .illegalStatus(let reason):
            return reason
        case .noAuth:
            return "noAuth"
        }
    }
    
}
