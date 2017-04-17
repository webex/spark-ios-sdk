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


/// A [JSON Web Token](https://jwt.io/introduction) (JWT) based authentication strategy
///
/// - since: 1.2.0
public class JWTAuthStrategy: Authenticator {
    private let client: JWTAuthClient
    private let storage: JWTAuthStorage
    private var tokenCompletionHandlers: [(String?) -> Void] = []
    
    private var unexpiredAccessToken: String? {
        guard authorized else {
            return nil
        }
        
        let buffer: TimeInterval = 15 * 60
        if let authenticationInfo = storage.authenticationInfo,
            authenticationInfo.accessTokenExpirationDate > Date(timeIntervalSinceNow: buffer) {
            return authenticationInfo.accessToken
        }
        return nil
    }
    
    private var unexpiredJwt: String? {
        guard let jwt = storage.jwt, let payload = JWTAuthStrategy.payloadFor(jwt: jwt) else {
            return nil
        }
        
        if let expiration = payload["exp"] as? TimeInterval {
            return Date(timeIntervalSince1970: expiration) > Date() ? jwt : nil
        }
        return jwt
    }
    
    /// - see: Authenticator.authorized
    public var authorized: Bool {
        return unexpiredJwt != nil
    }
    
    private static func payloadFor(jwt: String?) -> [String: Any]? {
        if let segments = jwt?.components(separatedBy: "."), 
            segments.count == 3,
            let payloadData = JWTAuthStrategy.base64UrlDecode(segments[1]) {
            return (try? JSONSerialization.jsonObject(with: payloadData, options: [])) as? [String: Any]
        }
        return nil
    }
    
    /// BASE64URL decoding algorithm is specified at https://tools.ietf.org/html/rfc7515#page-54
    private static func base64UrlDecode(_ base64UrlString: String) -> Data? {
        var base64String = base64UrlString
        base64String = base64String.replacingOccurrences(of: "-", with: "+")
        base64String = base64String.replacingOccurrences(of: "_", with: "/")
        switch base64String.characters.count % 4 {
        case 0:
            break
        case 2: 
            base64String += "=="
        case 3:
            base64String += "="
        default:
            SDKLogger.error("Base64Url encoded string could not be correctly decoded")
            return nil
        }
        return Data(base64Encoded: base64String)
    }

    /// Create a new JWT authentication strategy
    public convenience init(storage: JWTAuthStorage = JWTAuthKeychainStorage()) {
        self.init(storage: storage, client: JWTAuthClient())
    }
    
    init(storage: JWTAuthStorage, client: JWTAuthClient) {
        self.client = client
        self.storage = storage
    }
    
    /// Sets the JWT authorization on the authorization strategy, clearing any existing access token information
    ///
    /// - parameter jwt: the new JSON Web Token to use
    public func authorizedWith(jwt: String) {
        storage.jwt = jwt
        storage.authenticationInfo = nil
    }
    
    /// See Authenticator.deauthorize()
    public func deauthorize() {
        storage.jwt = nil
        storage.authenticationInfo = nil
    }
    
    /// See Authenticator.accessToken(completionHandler:)
    public func accessToken(completionHandler: @escaping (String?) -> Void) {
        tokenCompletionHandlers.append(completionHandler)
        if let jwt = unexpiredJwt, unexpiredAccessToken == nil {
            if tokenCompletionHandlers.count == 1 {
                client.fetchTokenFromJWT(jwt) { response in
                    switch response.result {
                    case .success(let jwtAccessTokenCreationResult):
                        if let authInfo = JWTAuthStrategy.authenticationInfoFrom(jwtAccessTokenCreationResult: jwtAccessTokenCreationResult) {
                            self.storage.authenticationInfo = authInfo
                        }
                    case .failure(let error):
                        self.deauthorize()
                        SDKLogger.error("Failed to refresh token", error: error)
                    }
                    self.fireCompletionHandlers()
                }
            }
        } else {
            fireCompletionHandlers()
        }
    }
    
    private func fireCompletionHandlers() {
        let accessToken = unexpiredAccessToken
        let handlers = tokenCompletionHandlers
        tokenCompletionHandlers = []
        for handler in handlers {
            handler(accessToken)
        }
    }
    
    private static func authenticationInfoFrom(jwtAccessTokenCreationResult: JWTAccessTokenCreationResult) -> JWTAuthenticationInfo? {
        if let token = jwtAccessTokenCreationResult.token,
            let tokenExpiration = jwtAccessTokenCreationResult.tokenExpiration {
            let tokenExpirationDate = Date(timeInterval: tokenExpiration, since: jwtAccessTokenCreationResult.tokenCreationDate)
            return JWTAuthenticationInfo(accessToken: token, accessTokenExpirationDate: tokenExpirationDate)
        }
        return nil
    }
}
