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

/// Authentication information for an OAuth authentication
///
/// - since: 1.2.0
public struct OAuthTokens {
    
    /// The OAuth access token, used throughout the SDK for authentication
    ///
    /// - since: 1.2.0
    public let accessToken: String
    
    /// The date and time at which the access token will expire
    ///
    /// - since: 1.2.0
    public let accessTokenExpirationDate: Date
    
    /// The OAuth refresh token, used to obtain a new access token
    ///
    /// - since: 1.2.0
    public let refreshToken: String
    
    /// The date and time at which the refresh token will expire.
    /// This will itself refresh every time the refresh token is used.
    ///
    /// - since: 1.2.0
    public let refreshTokenExpirationDate: Date
}

/// A delegate to handle OAuth events.
///
/// - since: 1.2.0
public protocol OAuthAuthenticatorDelegate: class {
    
    /// Called when an OAuth access token could not be created from the existing refresh token
    ///
    /// - since: 1.2.0
    func refreshAccessTokenFailed()
}

/// An [OAuth](https://oauth.net/2/) based authentication strategy
/// is to be used to authenticate a user on Cisco Spark.
///
/// - see: [Cisco Spark Integration](https://developer.ciscospark.com/authentication.html)
/// - since: 1.2.0
public class OAuthAuthenticator: Authenticator {
    
    let clientId: String
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
    public weak var delegate: OAuthAuthenticatorDelegate?
    
    /// - see: See Authenticator.authorized
    /// - since: 1.2.0
    public var authorized: Bool {
        if let refreshTokenExpirationDate = storage.tokens?.refreshTokenExpirationDate {
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
    /// - see: [Cisco Spark Integration](https://developer.ciscospark.com/authentication.html)
    /// - since: 1.2.0
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
    
    /// Brings up a web-based authorization view controller and directs the user through the OAuth process.
    ///
    /// - parameter parentViewController: the parent view controller for the OAuth view controller
    /// - parameter completionHandler: the completion handler will be called when authentication is complete, with a boolean to indicate if the authentication process was successful. It will be called directly after the OAuth view controller has begun to dismiss itself in an animated way.
    /// - since: 1.2.0
    public func authorize(parentViewController: UIViewController, completionHandler: ((_ success: Bool) -> Void)? = nil) {
        if let authorizationUrl = self.authorizationUrl() {
            oauthLauncher.launchOAuthViewController(parentViewController: parentViewController, authorizationUrl: authorizationUrl, redirectUri: redirectUri) { oauthCode in
                if let oauthCode = oauthCode {
                    self.fetchingAccessTokenInProcess = true
                    self.oauthClient.fetchAccessTokenFrom(oauthCode: oauthCode, clientId: self.clientId, clientSecret: self.clientSecret, redirectUri: self.redirectUri, completionHandler: { response in
                        self.createAccessTokenHandler(errorHandler: { error in SDKLogger.shared.error("Failure retrieving the access token from the oauth code", error: error)})(response)
                        completionHandler?(true)
                    })
                } else {
                    completionHandler?(false)
                }
            }
        } else {
            SDKLogger.shared.error("Bad URL")
            completionHandler?(false)
        }
    }
    
    func authorizationUrl() -> URL? {
        if let encodedClientId = clientId.encodeQueryParamString,
           let encodedRedirectUri = redirectUri.encodeQueryParamString,
           let encodedScope = scope.encodeQueryParamString {
           return URL(string: "https://api.ciscospark.com/v1/authorize?response_type=code"
                + "&client_id=" + encodedClientId
                + "&redirect_uri=" + encodedRedirectUri
                + "&scope=" + encodedScope
                + "&state=iossdkstate")
        }
        
        return nil
    }

    /// - see: See Authenticator.accessToken(completionHandler:)
    /// - since: 1.2.0
    public func accessToken(completionHandler: @escaping (String?) -> Void) {
        guard authorized else {
            completionHandler(nil)
            return
        }
        let buffer: TimeInterval = 15 * 60
        if let tokens = storage.tokens, tokens.accessTokenExpirationDate > Date(timeInterval: buffer, since: clock.currentTime) {
            completionHandler(tokens.accessToken)
        } else {
            accessTokenCompletionHandlers.append(completionHandler)
            
            if !fetchingAccessTokenInProcess, let refreshToken = storage.tokens?.refreshToken {
                fetchingAccessTokenInProcess = true
                oauthClient.refreshAccessTokenFrom(refreshToken: refreshToken, clientId: clientId, clientSecret: clientSecret, completionHandler: self.createAccessTokenHandler(errorHandler: { error in
                    SDKLogger.shared.error("Failed to refresh token", error: error)
                    self.deauthorize()
                    self.delegate?.refreshAccessTokenFailed()
                }))
            }
        }
    }
    
    private func createAccessTokenHandler(errorHandler: @escaping (Error)->Void) -> (ServiceResponse<OAuthTokenModel>) -> Void {
        return { response in
            self.fetchingAccessTokenInProcess = false
            
            switch response.result {
            case .success(let accessTokenObject):
                self.storage.tokens = OAuthAuthenticator.authenticationInfoFrom(accessTokenObject: accessTokenObject)
            case .failure(let error):
                errorHandler(error)
            }

            let handlers = self.accessTokenCompletionHandlers
            self.accessTokenCompletionHandlers = []
            for handler in handlers {
                handler(self.storage.tokens?.accessToken)
            }

        }
    }
    
    private static func authenticationInfoFrom(accessTokenObject: OAuthTokenModel) -> OAuthTokens? {
        if let accessToken = accessTokenObject.accessTokenString,
            let accessTokenExpiration = accessTokenObject.accessTokenExpiration,
            let refreshToken = accessTokenObject.refreshTokenString,
            let refreshTokenExpiration = accessTokenObject.refreshTokenExpiration {
            let accessTokenExpirationDate = Date(timeInterval: accessTokenExpiration, since: accessTokenObject.accessTokenCreationDate)
            let refreshTokenExpirationDate = Date(timeInterval: refreshTokenExpiration, since: accessTokenObject.accessTokenCreationDate)
            return OAuthTokens(accessToken: accessToken,
                                           accessTokenExpirationDate: accessTokenExpirationDate,
                                           refreshToken: refreshToken,
                                           refreshTokenExpirationDate: refreshTokenExpirationDate)
        }
        return nil
    }
    
    /// - see: See Authenticator.deauthorize()
    /// - since: 1.2.0
    public func deauthorize() {
        storage.tokens = nil
    }
}
