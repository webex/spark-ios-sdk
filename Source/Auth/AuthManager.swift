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

class AuthManager {
    
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
    
    private var accessToken: AccessToken? {
        get {
            if accessTokenCache == nil {
                accessTokenCache = KeychainManager.sharedInstance.fetchAccessToken()
            }
            
            return accessTokenCache
        }
        set {
            accessTokenCache = newValue
            KeychainManager.sharedInstance.storeAccessToken(newValue)
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
            KeychainManager.sharedInstance.storeClientAccount(newValue)
        }
    }
    
    func authorize(clientAccount clientAccount: ClientAccount, scope: String, redirectUri: String, controller: UIViewController) {
        self.clientAccount = clientAccount
        self.scope = scope
        self.redirectUri = redirectUri
        
        authorizeFromController(controller)
    }
    
    func authorize(token token: String) {
        accessToken = AccessToken(accessToken: token)
    }
    
    func deauthorize() {
        accessToken = nil
        clientAccount = nil
    }
    
    func authorized() -> Bool {
        guard let _ = accessToken?.accessTokenString else {
            return false
        }
        
        guard refreshAccessTokenWithExpirationBuffer(AccessTokenExpirationBufferInMinutes) else {
            return false
        }
        
        return true
    }
    
    func getAuthorization() -> [String: String]? {
        guard refreshAccessTokenWithExpirationBuffer(AccessTokenExpirationBufferInMinutes) else {
            return nil
        }
        
        if let accessTokenString = self.accessToken?.accessTokenString {
            return ["Authorization": "Bearer " + accessTokenString]
        }
        
        return nil
    }
    
    private func authorizeFromController(controller: UIViewController) {
        guard isOAuthMode else {
            return
        }
        
        let url = createAuthCodeRequestURL()
        let web = ConnectController(URL: url) { url in
            if let accessToken = self.fetchAccessTokenFromRedirectUri(url) {
                self.accessToken = accessToken
                return true
            }
            return false
        }
        
        let navigationController = UINavigationController(rootViewController: web)
        controller.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func createAuthCodeRequestURL() -> NSURL {
        let components = NSURLComponents(string: "https://api.ciscospark.com/v1/authorize")!
        components.queryItems = [
            NSURLQueryItem(name: "client_id", value: (clientAccount?.clientId)!),
            NSURLQueryItem(name: "response_type", value: "code"),
            NSURLQueryItem(name: "redirect_uri", value: redirectUri!.encodeString),
            NSURLQueryItem(name: "scope", value: scope!.encodeString),
            NSURLQueryItem(name: "state", value: "set_state_here")]
        components.percentEncodedQuery = components.query
        
        return components.URL!
    }
    
    private func fetchAccessTokenFromRedirectUri(url: NSURL) -> AccessToken? {
        guard url.absoluteString.lowercaseString.containsString(redirectUri!.lowercaseString) else {
            return nil
        }
        
        let query = url.queryParameters
        if let error = query["error"] {
            Logger.error("ErrorCode: \(error)")
            if let description = query["error_description"] {
                Logger.error("Error description: \(description.decodeString!)")
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
    
    private func refreshAccessTokenWithExpirationBuffer(bufferInMinutes: Int) -> Bool {
        guard accessTokenWillExpireInMinutes(bufferInMinutes) else {
            return true
        }
        
        return refreshAccessToken()
    }
    
    private func accessTokenWillExpireInMinutes(minutes: Int) -> Bool {
        // Assume access token (authorized with signle token instead of OAuth parameters) won't expire.
        guard isOAuthMode else {
            return false
        }
        
        let thresholdDate = NSDate(timeInterval: Double(minutes*60), sinceDate: NSDate())
        let expirationdate = accessToken!.accessTokenExpirationDate
        return thresholdDate.isAfterDate(expirationdate)
    }
    
    private func refreshAccessToken() -> Bool {
        do {
            let accessToken = try OAuthClient().refreshAccessTokenFromRefreshToken((self.accessToken?.refreshTokenString)!, clientAccount: clientAccount!)
            accessToken.refreshTokenString = self.accessToken?.refreshTokenString
            accessToken.refreshTokenExpiration = self.accessToken?.refreshTokenExpiration
            self.accessToken = accessToken
            
        } catch let error as NSError {
            deauthorize()
            Logger.error("Failed to refresh token: \(error.localizedFailureReason)")
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Phone.RefreshAccessTokenFailed, object: nil)
            return false
        }
        
        return true
    }
}