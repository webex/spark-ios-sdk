//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import Alamofire

struct OAuthConstants {
    
    static let OAuthBaseUrl = "https://api.ciscospark.com"
    static let authorizePath = "/v1/authorize"
    static let accessTokenPath = "/v1/access_token"
    static let grantType = "authorization_code"
    static let contentType = "application/x-www-form-urlencoded"
}

class AuthManagerUtils {
    
    static func decodeString(string: String?) -> String? {
        return string?.stringByReplacingOccurrencesOfString("+", withString: " ").stringByRemovingPercentEncoding
    }
    
    static func encodeString(string: String?) -> String? {
        return string?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
    }
    
    static func authURL(clientId clientId: String, scope: String, redirectUri: String) -> NSURL {
        let components = NSURLComponents(string: OAuthConstants.OAuthBaseUrl)!
        components.path = OAuthConstants.authorizePath
        
        components.queryItems = [
            NSURLQueryItem(name: "client_id", value: clientId),
            NSURLQueryItem(name: "response_type", value: "code"),
            NSURLQueryItem(name: "redirect_uri", value: encodeString(redirectUri)),
            NSURLQueryItem(name: "scope", value: encodeString(scope)),
            NSURLQueryItem(name: "state", value: "set_state_here"),
        ]
        components.percentEncodedQuery = components.query
        
        return components.URL!
    }
    
    static func extractQueryFromRedirectUri(url: NSURL) -> [String: String] {
        var query = [String: String]()
        let pairs  = url.query?.componentsSeparatedByString("&") ?? []
        
        for pair in pairs {
            let kv = pair.componentsSeparatedByString("=")
            query.updateValue(kv[1], forKey: kv[0])
        }
        
        return query
    }
}

class AuthManager {
    static var sharedInstance = AuthManager()
    
    var accessToken: AccessToken?
    private var mode: Mode
    
    private enum Mode {
        case OAuth(clientId: String, clientSecret: String, scope: String, redirectUri: String)
        case Token(token: String)
        case None
        
        func get() -> Any? {
            switch (self) {
            case .OAuth(clientId: let clientId, clientSecret: let clientSecret, scope: let scope, redirectUri: let redirectUri):
                return (clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
            case .Token(token: let token):
                return token
            default:
                return nil
            }
        }
    }

    init() {
        mode = Mode.None
    }
    
    func setup(clientId clidentId: String, clientSecret: String, scope: String, redirectUri: String) {
        mode = Mode.OAuth(clientId: clidentId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri.lowercaseString)
    }
    
    func setup(token token: String) {
        mode = Mode.Token(token: token)
        accessToken = AccessToken(accessToken: token)
    }
    
    func invalidateAccessToken() {
        mode = Mode.None
        accessToken = nil
        KeychainUtil.removeAccessTokenFromKeychain()
    }
    
    func authorizeFromController(controller: UIViewController) {
        
        switch (mode) {
        case .OAuth(clientId: _, clientSecret: _, scope: _, redirectUri: _):
            break
        default:
            return
        }
        
        let (clientId, clientSecret, scope, redirectUri) = mode.get() as! (String, String, String, String)
        
        let web = ConnectController(URL: AuthManagerUtils.authURL(clientId: clientId, scope: scope, redirectUri: redirectUri)) { url in
            if let authResult = self.fetchAccessTokenFromRedirectUri(url, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri) {
                
                switch authResult {
                case .Success(let accessToken):
                    self.accessToken = accessToken
                    self.storeAccessTokenToKeychain()
                    return true
                case .Error:
                    return false
                }
            }
            return false
        }
        
        let navigationController = UINavigationController(rootViewController: web)
        controller.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    //TODO: need to add refresh token logic
    func authorization() -> String? {
        
        if let accessToken = self.accessToken {
            return "Bearer " + accessToken.accessTokenString!
        }
        
        return nil
    }
    
    func authorized() -> Bool {
        if let token = fetchAccessTokenFromKeychain() {
            accessToken = token
            return accessToken?.accessTokenString != nil
        }
        return false
    }
    
    private func fetchAccessTokenFromRedirectUri(url: NSURL, clientId: String, clientSecret: String, redirectUri: String) -> AuthResult? {
        
        guard url.absoluteString.lowercaseString.containsString(redirectUri) else {
            return nil
        }
        
        let query = AuthManagerUtils.extractQueryFromRedirectUri(url)
        if let error = query["error"] {
            let desc = AuthManagerUtils.decodeString(query["error_description"])
            return .Error(OAuth2Error(errorCode: error), desc ?? "")
            
        } else {
            if let authCode = query["code"] {
                return fetchAccessTokenFromOAuthCode(authCode, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri)
            } else {
                return nil
            }
        }
    }
    
    private func fetchAccessTokenFromOAuthCode(code: String, clientId: String, clientSecret: String, redirectUri: String) -> AuthResult? {
        
        let body = ["grant_type": OAuthConstants.grantType,
                    "redirect_uri": redirectUri,
                    "code": code,
                    "client_id": clientId,
                    "client_secret": clientSecret]
        
        let headers = ["Content-Type": OAuthConstants.contentType]
        let url = OAuthConstants.OAuthBaseUrl + OAuthConstants.accessTokenPath
        
        let semaphore = dispatch_semaphore_create(0)
        let queue: dispatch_queue_t? = dispatch_queue_create("com.cisco.fetchtokenqueue", nil)
        var result: AuthResult? = nil
        
        Alamofire.request(.POST, url, parameters: body, headers: headers)
            .responseObject(queue: queue) {
                (response: Response<AccessToken, NSError>) in
                
                switch response.result {
                case .Success:
                    self.accessToken = response.result.value
                    result = AuthResult.Success(self.accessToken!)
                case .Failure(let error):
                    result = AuthResult.Error(.Unknown, error.localizedDescription)
                }
                dispatch_semaphore_signal(semaphore)
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return result
    }
    
    private func storeAccessTokenToKeychain() {
        let accessTokenData = NSKeyedArchiver.archivedDataWithRootObject(accessToken!)
        KeychainUtil.storeTokenDataInKeychain(accessTokenData)
    }
    
    private func fetchAccessTokenFromKeychain() -> AccessToken? {
        if let accessTokenData = KeychainUtil.fetchTokenDataFromKeychain() {
            return NSKeyedUnarchiver.unarchiveObjectWithData(accessTokenData) as? AccessToken
        } else {
            return nil
        }
    }
    
}