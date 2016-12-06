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


/// A JWT-based authentication strategy
public class JWTAuthStrategy: AuthenticationStrategy {
    private let client: JWTAuthClient
    private let storage: JWTAuthStorage
    
    public var authorized: Bool {
        guard let payload = JWTAuthStrategy.payloadFor(jwt: storage.jwt) else {
            return false
        }
        
        if let expiration = payload["exp"] as? TimeInterval {
            return Date(timeIntervalSince1970: expiration) > Date()
        }
        return true
    }
    
    private static func payloadFor(jwt: String?) -> [String: Any]? {
        if let segments = jwt?.components(separatedBy: "."), 
            segments.count == 3,
            let payloadData = JWTAuthStrategy.base64UrlDecode(segments[1]) {
            return (try? JSONSerialization.jsonObject(with: payloadData, options: [])) as? [String: Any]
        }
        return nil
    }
    
    /*
     BASE64URL decoding algorithm is specified at https://tools.ietf.org/html/rfc7515#page-54
     */
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
            Logger.error("Base64Url encoded string could not be correctly decoded")
            return nil
        }
        return Data(base64Encoded: base64String)
    }
    
    init(storage: JWTAuthStorage = JWTAuthKeychainStorage(), client: JWTAuthClient = JWTAuthClient()) {
        self.client = client
        self.storage = storage
    }
     
    public func authorizedWith(jwt: String) {
        storage.jwt = jwt
        storage.authenticationInfo = nil
    }
    
    public func deauthorize() {
        storage.jwt = nil
        storage.authenticationInfo = nil
    }
    
    public func accessToken(completionHandler: @escaping (String?) -> Void) {
        guard authorized, let jwt = storage.jwt else {
            completionHandler(nil)
            return
        }
        let buffer: TimeInterval = 15 * 60
        if let authenticationInfo = storage.authenticationInfo,
            authenticationInfo.accessTokenExpirationDate > Date(timeIntervalSinceNow: buffer) {
            completionHandler(authenticationInfo.accessToken)
        } else {
            client.fetchTokenFromJWT(jwt) { response in
                switch response.result {
                case .success(let jwtAccessTokenCreationResult):
                    if let authInfo = JWTAuthStrategy.authenticationInfoFrom(jwtAccessTokenCreationResult: jwtAccessTokenCreationResult) {
                        self.storage.authenticationInfo = authInfo
                    }
                case .failure(let error):
                    self.deauthorize()
                    Logger.error("Failed to refresh token", error: error)
                }
                completionHandler(self.storage.authenticationInfo?.accessToken)
            }
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
