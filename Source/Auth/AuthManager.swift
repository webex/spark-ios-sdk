// Copyright 2016 Cisco Systems Inc
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

class AuthManager : AuthenticationStrategy {
    
    static var sharedInstance = AuthManager()
    
    private var accessTokenCache: AccessToken?

    // OAuth parameters
    private var clientAccountCache: ClientAccount?
    private var scope: String?
    private var redirectUri: String?
    
    private let AccessTokenExpirationBufferInMinutes = 15
    
    // OAuth flow has client account
    private var isOAuthMode: Bool {
        return clientAccount != nil
    }
    
    private var accessTokenObject: AccessToken? {
        get {
            if accessTokenCache == nil {
                accessTokenCache = KeychainManager.sharedInstance.fetchAccessToken()
            }
            
            return accessTokenCache
        }
        set {
            accessTokenCache = newValue
            KeychainManager.sharedInstance.store(accessToken: newValue)
        }
    }
    
    private var clientAccount: ClientAccount? {
        get {
            if clientAccountCache == nil {
                clientAccountCache = KeychainManager.sharedInstance.fetchClientAccount()
            }
            
            return clientAccountCache
        }
        set {
            clientAccountCache = newValue
            KeychainManager.sharedInstance.store(clientAccount: newValue)
        }
    }
    
    var authorized: Bool {
        get {
            guard let _ = accessTokenObject?.accessTokenString else {
                return false
            }
            
            return refreshAccessTokenWithExpirationBuffer(AccessTokenExpirationBufferInMinutes)			
        }
    }
	
    // XXX This is basically the init for the OAuthStrategy
    func authorize(clientAccount: ClientAccount, scope: String, redirectUri: String, controller: UIViewController) {
        self.clientAccount = clientAccount
        self.scope = scope
        self.redirectUri = redirectUri
        
        authorizeFrom(controller: controller)
    }
	
    // XXX This is basically the init for the SimpleStrategy
    func authorize(token: String) {
        accessTokenObject = AccessToken(accessToken: token)
    }
    
    func deauthorize() {
        accessTokenObject = nil
        clientAccount = nil
    }
    
    func accessToken() -> String? {
        guard refreshAccessTokenWithExpirationBuffer(AccessTokenExpirationBufferInMinutes) else {
            return nil
        }
        return self.accessTokenObject?.accessTokenString 
    }
    
    func accessToken(completionHandler: @escaping (String?) -> Void) {
        completionHandler(accessToken())
    }
    
    private func authorizeFrom(controller: UIViewController) {
        guard isOAuthMode else {
            return
        }
        
        let url = createAuthCodeRequestURL()
        let web = ConnectController(URL: url) { url in
            if let accessTokenObject = self.fetchAccessTokenFromRedirectUri(url) {
                self.accessTokenObject = accessTokenObject
                return true
            }
            return false
        }
        
        let navigationController = UINavigationController(rootViewController: web)
        controller.present(navigationController, animated: true, completion: nil)
    }
    
    private func createAuthCodeRequestURL() -> URL {
        var components = URLComponents(string: "https://api.ciscospark.com/v1/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: (clientAccount?.clientId)!),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri!.encodeQueryParamString),
            URLQueryItem(name: "scope", value: scope!.encodeQueryParamString),
            URLQueryItem(name: "state", value: "set_state_here")]
        components.percentEncodedQuery = components.query
        
        return components.url!
    }
    
    private func fetchAccessTokenFromRedirectUri(_ url: URL) -> AccessToken? {
        guard url.absoluteString.lowercased().contains(redirectUri!.lowercased()) else {
            return nil
        }
        
        let query = url.queryParameters
        if let error = query["error"] {
            Logger.error("ErrorCode: \(error)")
            if let description = query["error_description"] {
                Logger.error("Error description: \(description.decodeString)")
            }
        } else if let authCode = query["code"] {
            do {
                return try OAuthClient().fetchAccessTokenFromOAuthCode(authCode, clientAccount: clientAccount!, redirectUri: redirectUri!)
            }  catch let error as NSError {
                Logger.error("Failed to fetch access token: \(error.localizedFailureReason)")
            }
        }
        
        return nil
    }
    
    // XXX this refresh call is blocking and so is dangerous to use from the UI thread
    private func refreshAccessTokenWithExpirationBuffer(_ bufferInMinutes: Int) -> Bool {
        guard accessTokenWillExpireInMinutes(bufferInMinutes) else {
            return true
        }
        
        return refreshAccessToken()
    }
    
    private func accessTokenWillExpireInMinutes(_ minutes: Int) -> Bool {
        // Assume access token (authorized with signle token instead of OAuth parameters) won't expire.
        guard isOAuthMode else {
            return false
        }
        
        let thresholdDate = Date(timeInterval: Double(minutes*60), since: Date())
        let expirationdate = accessTokenObject!.accessTokenExpirationDate
        return thresholdDate.isAfterDate(expirationdate)
    }
    
    private func refreshAccessToken() -> Bool {
        do {
            let accessTokenObject = try OAuthClient().refreshAccessTokenFromRefreshToken((self.accessTokenObject?.refreshTokenString)!, clientAccount: clientAccount!)
            accessTokenObject.refreshTokenString = self.accessTokenObject?.refreshTokenString
            accessTokenObject.refreshTokenExpiration = self.accessTokenObject?.refreshTokenExpiration
            self.accessTokenObject = accessTokenObject
            
        } catch let error as NSError {
            deauthorize()
            Logger.error("Failed to refresh token: \(error.localizedFailureReason)")
            PhoneNotificationCenter.sharedInstance.notifyRefreshAccessTokenFailed()
            return false
        }
        
        return true
    }
}
