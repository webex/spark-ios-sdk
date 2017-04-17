import Foundation

class OAuthUrlUtil {
    static func url(_ url: URL, matchesRedirectUri redirectUri: String) -> Bool {
        // XXX This is insufficient, but was the existing behavior
        return url.absoluteString.lowercased().contains(redirectUri.lowercased())
    }
    
    static func oauthCodeFor(redirectUrl: URL) -> String? {
        let query = redirectUrl.queryParameters
        if let error = query["error"] {
            SDKLogger.error("ErrorCode: \(error)")
            if let description = query["error_description"] {
                SDKLogger.error("Error description: \(String(describing: description.decodeString))")
            }
        } else if let authCode = query["code"] {
            return authCode
        }
        return nil
    }
}
