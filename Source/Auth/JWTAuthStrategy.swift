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
    private var jwt: String
    private var client: JWTAuthClient
    private var storage: JWTAuthStorage
    
    public var authorized: Bool {
        get {
            return jwtValid && storage.authenticationInfo != nil
        }
    }
    
    private var jwtValid: Bool {
        let segments = jwt.components(separatedBy: ".")
        if segments.count != 3 {
            return false
        }
        let payloadSegment = segments[1]
        if let payloadData = base64decode(payloadSegment),
            let payload = (try? JSONSerialization.jsonObject(with: payloadData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? [String: Any],
            let expiration = payload["exp"] as? TimeInterval {
            return Date(timeIntervalSince1970: expiration) > Date()
        } else {
            return false
        }
    }
    
    init(jwt: String, storage: JWTAuthStorage = JWTAuthKeychainStorage(), client: JWTAuthClient = JWTAuthClient()) {
        self.jwt = jwt
        self.client = client
        self.storage = storage
    }
    
    private static func authenticationInfoFrom(jwtAccessTokenCreationResult: JWTAccessTokenCreationResult) -> JWTAuthenticationInfo? {
        if let token = jwtAccessTokenCreationResult.token,
            let tokenExpiration = jwtAccessTokenCreationResult.tokenExpiration {
            let tokenExpirationDate = Date(timeInterval: tokenExpiration, since: jwtAccessTokenCreationResult.tokenCreationDate)
            return JWTAuthenticationInfo(token: token,
                                           tokenExpirationDate: tokenExpirationDate)
        }
        return nil
    }
    
    public func deauthorize() {
        self.storage.authenticationInfo = nil
    }
    
    public func accessToken(completionHandler: @escaping (String?) -> Void) {
        guard authorized else {
            completionHandler(nil)
            return
        }
        let buffer: TimeInterval = 15 * 60
        if let authenticationInfo = storage.authenticationInfo,
            authenticationInfo.tokenExpirationDate > Date(timeIntervalSinceNow: buffer) {
            completionHandler(authenticationInfo.token)
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
                completionHandler(self.storage.authenticationInfo?.token)
            }
        }
    }
    
    private func base64decode(_ input:String) -> Data? {
        let rem = input.characters.count % 4
        
        var ending = ""
        if rem > 0 {
            let amount = 4 - rem
            ending = String(repeating: "=", count: amount)
        }
        
        let base64 = input.replacingOccurrences(of: "-", with: "+", options: NSString.CompareOptions(rawValue: 0), range: nil)
            .replacingOccurrences(of: "_", with: "/", options: NSString.CompareOptions(rawValue: 0), range: nil) + ending
        
        return Data(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))
    }
}
