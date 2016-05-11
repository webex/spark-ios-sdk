//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

enum AuthResult {
    case Success(AccessToken)
    case Error(OAuth2Error, String)
}

/// See RFC6749 4.2.2.1
enum OAuth2Error {
    /// The client is not authorized to request an access token using this method.
    case UnauthorizedClient
    
    /// The resource owner or authorization server denied the request.
    case AccessDenied
    
    /// The authorization server does not support obtaining an access token using this method.
    case UnsupportedResponseType
    
    /// The requested scope is invalid, unknown, or malformed.
    case InvalidScope
    
    /// The authorization server encountered an unexpected condition that prevented it from fulfilling the request.
    case ServerError
    
    /// The authorization server is currently unable to handle the request due to a temporary overloading or maintenance of the server.
    case TemporarilyUnavailable
    
    /// Some other error (outside of the OAuth2 specification)
    case Unknown
    
    /// Initializes an error code from the string specced in RFC6749
    init(errorCode: String) {
        switch errorCode {
        case "unauthorized_client": self = .UnauthorizedClient
        case "access_denied": self = .AccessDenied
        case "unsupported_response_type": self = .UnsupportedResponseType
        case "invalid_scope": self = .InvalidScope
        case "server_error": self = .ServerError
        case "temporarily_unavailable": self = .TemporarilyUnavailable
        default: self = .Unknown
        }
    }
}
