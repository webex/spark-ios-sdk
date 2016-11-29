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

public protocol SparkViewControllerProvider {
    var viewController: UIViewController { get }
}

public class OAuthStrategy : AuthenticationStrategy {
    private let clientAccount: ClientAccount
    private let scope: String
    private let redirectUri: String
    private let storage: OAuthStorage
    private let oauthClient: OAuthClient
    
    public var authorized: Bool { 
        get {
            if let authenticationInfo = storage.authenticationInfo {
                return authenticationInfo.refreshTokenExpirationDate > Date()
            } else {
                return false
            }
        }
    }
    
    private struct SimpleSparkViewControllerProvider : SparkViewControllerProvider {
        let viewController: UIViewController
    }
    
    init(clientAccount: ClientAccount, scope: String, redirectUri: String, storage: OAuthStorage = OAuthKeychainStorage(), oauthClient: OAuthClient = OAuthClient()) {
        self.clientAccount = clientAccount
        self.scope = scope
        self.redirectUri = redirectUri
        self.storage = storage
        self.oauthClient = oauthClient
    }
    
    func authorize(parentViewController: UIViewController, completionHandler: ((Bool) -> Void)?) {
        let url = createAuthCodeRequestURL()
        let web = ConnectController(URL: url) { url in
            let success: Bool
            if let accessTokenObject = self.fetchAccessTokenFromRedirectUri(url),
                let authInfo = OAuthStrategy.authenticationInfoFrom(accessTokenObject: accessTokenObject) {
                self.storage.authenticationInfo = authInfo
                success = true
            } else {
                success = false
            }
            completionHandler?(success)
            return success
        }
        
        let navigationController = UINavigationController(rootViewController: web)
        parentViewController.present(navigationController, animated: true, completion: nil)
    }
    
    private static func authenticationInfoFrom(accessTokenObject: AccessToken) -> OAuthAuthenticationInfo? {
        if let accessToken = accessTokenObject.accessTokenString,
            let accessTokenExpiration = accessTokenObject.accessTokenExpiration,
            let refreshToken = accessTokenObject.refreshTokenString,
            let refreshTokenExpiration = accessTokenObject.refreshTokenExpiration {
            let accessTokenExpirationDate = Date(timeInterval: accessTokenExpiration, since: accessTokenObject.accessTokenCreationDate)
            let refreshTokenExpirationDate = Date(timeInterval: refreshTokenExpiration, since: accessTokenObject.accessTokenCreationDate)
            return OAuthAuthenticationInfo(accessToken: accessToken,
                                           accessTokenExpirationDate: accessTokenExpirationDate,
                                           refreshToken: refreshToken,
                                           refreshTokenExpirationDate: refreshTokenExpirationDate)
        }
        return nil
    }
    
    public func deauthorize() {
        storage.authenticationInfo = nil
    }
    
    public func accessToken(completionHandler: @escaping (String?) -> Void) {
        guard authorized, let authenticationInfo = storage.authenticationInfo else {
            completionHandler(nil)
            return
        }
        let buffer: TimeInterval = 15 * 60
        if authenticationInfo.accessTokenExpirationDate > Date(timeIntervalSinceNow: buffer) {
            completionHandler(authenticationInfo.accessToken)
        } else {
            oauthClient.refreshOAuthAccessTokenFromRefreshToken(authenticationInfo.refreshToken, clientAccount) { response in
                switch response.result {
                case .success(let accessTokenObject):
                    if let authInfo = OAuthStrategy.authenticationInfoFrom(accessTokenObject: accessTokenObject) {
                        self.storage.authenticationInfo = authInfo
                    }
                case .failure(let error):
                    self.deauthorize()
                    Logger.error("Failed to refresh token", error: error)
                    PhoneNotificationCenter.sharedInstance.notifyRefreshAccessTokenFailed()
                }
                completionHandler(self.storage.authenticationInfo?.accessToken)
            }
        }
    }
    
    private func createAuthCodeRequestURL() -> URL {
        var components = URLComponents(string: "https://api.ciscospark.com/v1/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientAccount.clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri.encodeQueryParamString),
            URLQueryItem(name: "scope", value: scope.encodeQueryParamString),
            URLQueryItem(name: "state", value: "set_state_here")]
        components.percentEncodedQuery = components.query
        
        return components.url!
    }
    
    private func fetchAccessTokenFromRedirectUri(_ url: URL) -> AccessToken? {
        guard url.absoluteString.lowercased().contains(redirectUri.lowercased()) else {
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
                return try OAuthClient().fetchAccessTokenFromOAuthCode(authCode, clientAccount: clientAccount, redirectUri: redirectUri)
            }  catch let error as NSError {
                Logger.error("Failed to fetch access token: \(error.localizedFailureReason)")
            }
        }

        return nil
    }

}
