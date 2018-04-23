// Copyright 2016-2018 Cisco Systems Inc
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
import KeychainAccess


/// A JWTAuthStorage implementation based on the iOS device keychain.
///
/// - since: 1.2.0
public class JWTAuthKeychainStorage: JWTAuthStorage {
    
    private let jwtKey = "jwtKey"
    private let accessTokenKey = "accessTokenKey"
    private let accessTokenExpirationDateKey = "accessTokenExpirationDateKey"
    private let keychain: KeychainProtocol
    private var cachedJwt: String?
    private var cachedAuthenticationInfo: JWTAuthenticationInfo?
    
    /// Contructs a new JWTAuthKeychainStorage
    ///
    /// - since: 1.2.0
    public convenience init() {
        self.init(keychain: Keychain(service: "\(Bundle.main.bundleIdentifier ?? "").sparksdk.jwtauth"))
    }
    
    init(keychain: KeychainProtocol) {
        self.keychain = keychain
    }
    
    /// - see: see JWTAuthKeychainStorage.jwt
    /// - since: 1.2.0
    public var jwt: String? {
        get {
            do {
                if cachedJwt == nil, 
                    let jwt = try keychain.get(jwtKey) {
                    cachedJwt = jwt
                }
            } catch let error {
                SDKLogger.shared.error("Failed to get JWT with error", error: error)
            }
            return cachedJwt
        }
        set {
            cachedJwt = newValue
            do {
                if let newValue = newValue {
                    try keychain.set(newValue, key: jwtKey)
                } else {
                    try keychain.remove(jwtKey)
                }
            } catch let error {
                SDKLogger.shared.error("Failed to save JWT with error", error: error)
            }
        }
    }
    
    /// - see: see JWTAuthKeychainStorage.authenticationInfo
    /// - since: 1.2.0
    public var authenticationInfo: JWTAuthenticationInfo? {
        get {
            do {
                if cachedAuthenticationInfo == nil,
                    let accessToken = try keychain.get(accessTokenKey),
                    let expirationDateString = try keychain.get(accessTokenExpirationDateKey),
                    let expirationDateDouble = Double(expirationDateString) {
                    let expirationDate = Date(timeIntervalSinceReferenceDate: expirationDateDouble)
                    cachedAuthenticationInfo = JWTAuthenticationInfo(accessToken: accessToken, accessTokenExpirationDate: expirationDate)
                }
            } catch let error {
                SDKLogger.shared.error("Failed to get authentication information with error", error: error)
            }
            return cachedAuthenticationInfo            
        }
        set {
            cachedAuthenticationInfo = newValue
            do {
                if let newValue = newValue {
                    try keychain.set(newValue.accessToken, key: accessTokenKey)
                    try keychain.set(String(newValue.accessTokenExpirationDate.timeIntervalSinceReferenceDate), key: accessTokenExpirationDateKey)
                } else {
                    try keychain.remove(accessTokenKey)
                    try keychain.remove(accessTokenExpirationDateKey)
                }
            } catch let error {
                SDKLogger.shared.error("Failed to save authentication information with error", error: error)
            }
        }
    }  
}
