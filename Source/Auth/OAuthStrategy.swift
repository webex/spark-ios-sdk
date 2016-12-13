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


/// A delegate to handle some events
public protocol OAuthStrategyDelegate: class {
    
    /// Called when an OAuth access token could not be created from the existing refresh token
    func refreshAccessTokenFailed()
}

/// An authentication strategy that uses Spark's OAuth2 mechanism to provide access tokens
public class OAuthStrategy: AuthenticationStrategy {
    
    private let clientId: String
    private let clientSecret: String
    private let scope: String
    private let redirectUri: String
    private let storage: OAuthStorage
    private let oauthClient: OAuthClient
    private let oauthLauncher: OAuthLauncher
    private let clock: Clock
    private var accessTokenCompletionHandlers: [(_ accessToken: String?) -> Void] = []
    private var fetchingAccessTokenInProcess = false
    
    
    /// The delegate, which gets callbacks for refresh access token failure
    public weak var delegate: OAuthStrategyDelegate?
    
    /// Returns true if the user has already been authorized
    public var authorized: Bool {
        if let refreshTokenExpirationDate = storage.authenticationInfo?.refreshTokenExpirationDate {
            return refreshTokenExpirationDate > clock.currentTime
        } else {
            return fetchingAccessTokenInProcess
        }
    }
    
    /// Creates a new OAuth authentication strategy
    ///
    /// - parameter clientId: the OAuth client id
    /// - parameter clientSecret: the OAuth client secret
    /// - parameter scope: space-separated string representing which permissions the application needs
    /// - parameter redirectUri: the redirect URI that will be called when completing the authentication. This must match the redirect URI registered to your clientId.
    /// - parameter storage: the storage mechanism for persisting authentication information
    ///
    /// See https://developer.ciscospark.com/authentication.html
    public convenience init(clientId: String, clientSecret: String, scope: String, redirectUri: String,
                            storage: OAuthStorage = OAuthKeychainStorage()) {
        self.init(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri, storage: storage, oauthClient: OAuthClient(), oauthLauncher: OAuthLauncher(), clock: Clock())
    }
    
    init(clientId: String, clientSecret: String, scope: String, redirectUri: String,
         storage: OAuthStorage, oauthClient: OAuthClient, oauthLauncher: OAuthLauncher, clock: Clock) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.scope = scope
        self.redirectUri = redirectUri
        self.storage = storage
        self.oauthClient = oauthClient
        self.oauthLauncher = oauthLauncher
        self.clock = clock
    }
    
    /// Bring up a web-based authorization view controller and direct the user through the OAuth process.
    ///
    /// - parameter parentViewController: the parent view controller for the OAuth view controller
    /// - parameter completionHandler: the completion handler will be called when authentication is complete, with a boolean to
    ///                                indicate if the authentication process was successful. It will be called directly after
    ///                                the OAuth view controller has begun to dismiss itself in an animated way
    public func authorize(parentViewController: UIViewController, completionHandler: ((_ success: Bool) -> Void)? = nil) {
        let url = createAuthCodeRequestURL()
        oauthLauncher.launchOAuthViewController(parentViewController: parentViewController, authorizationUrl: url, redirectUri: redirectUri) { oauthCode in
            if let oauthCode = oauthCode {
                self.fetchingAccessTokenInProcess = true
                self.oauthClient.fetchAccessTokenFrom(oauthCode: oauthCode, clientId: self.clientId, clientSecret: self.clientSecret, redirectUri: self.redirectUri, completionHandler: self.createAccessTokenHandler(errorHandler: { error in
                    Logger.error("Failure retrieving the access token from the oauth code", error: error)
                }))
            }
            completionHandler?(oauthCode != nil)
        }
    }
    
    /// See AuthenticationStrategy.accessToken(completionHandler:)
    public func accessToken(completionHandler: @escaping (String?) -> Void) {
        guard authorized else {
            completionHandler(nil)
            return
        }
        let buffer: TimeInterval = 15 * 60
        if let authenticationInfo = storage.authenticationInfo, authenticationInfo.accessTokenExpirationDate > Date(timeInterval: buffer, since: clock.currentTime) {
            completionHandler(authenticationInfo.accessToken)
        } else {
            accessTokenCompletionHandlers.append(completionHandler)
            
            if !fetchingAccessTokenInProcess, let refreshToken = storage.authenticationInfo?.refreshToken {
                fetchingAccessTokenInProcess = true
                oauthClient.refreshAccessTokenFrom(refreshToken: refreshToken, clientId: clientId, clientSecret: clientSecret, completionHandler: self.createAccessTokenHandler(errorHandler: { error in
                    Logger.error("Failed to refresh token", error: error)
                    self.deauthorize()
                    self.delegate?.refreshAccessTokenFailed()
                    
                    // Intentional use of deprecated API for backwards compatibility
                    PhoneNotificationCenter.sharedInstance.notifyRefreshAccessTokenFailed()
                }))
            }
        }
    }
    
    private func createAccessTokenHandler(errorHandler: @escaping (Error)->Void) -> OAuthClient.ObjectHandler {
        return { response in
            self.fetchingAccessTokenInProcess = false
            
            switch response.result {
            case .success(let accessTokenObject):
                self.storage.authenticationInfo = OAuthStrategy.authenticationInfoFrom(accessTokenObject: accessTokenObject)
            case .failure(let error):
                errorHandler(error)
            }
            self.fireAccessTokenCompletionHandlers()
        }
    }
    
    private func fireAccessTokenCompletionHandlers() {
        let handlers = accessTokenCompletionHandlers
        accessTokenCompletionHandlers = []
        for handler in handlers {
            handler(storage.authenticationInfo?.accessToken)
        }
    }
    
    private func createAuthCodeRequestURL() -> URL {
        return URL(string: "https://api.ciscospark.com/v1/authorize?response_type=code"
            + "&client_id=" + clientId.encodeQueryParamString
            + "&redirect_uri=" + redirectUri.encodeQueryParamString
            + "&scope=" + scope.encodeQueryParamString
            + "&state=iossdkstate"
            )!
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
    
    /// See AuthenticationStrategy.deauthorize()
    public func deauthorize() {
        storage.authenticationInfo = nil
    }
}
