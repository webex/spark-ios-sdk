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
import KeychainAccess

/// An OAuthStorage mechanism that uses the keychain for underlying storage
public class OAuthKeychainStorage: OAuthStorage {

    private let accessTokenKey = "accessToken"
    private let accessTokenExpirationDateKey = "accessTokenExpirationDate"
    private let refreshTokenKey = "refreshToken"
    private let refreshTokenExpirationDateKey = "refreshTokenExpirationDate"
    
    private var cachedTokens: OAuthTokens?
    private let keychain: KeychainProtocol
    
    /// Creates a new OAuth keychain store
    public convenience init() {
        self.init(keychain: Keychain(service: "\(Bundle.main.bundleIdentifier ?? "").sparksdk.oauth"))
    }
    
    init(keychain: KeychainProtocol) {
        self.keychain = keychain
    }
    
    /// See OAuthStorage.authenticationInfo
    public var tokens: OAuthTokens? {
        get {
            do {
                if cachedTokens == nil,
                    let accessToken = try keychain.get(accessTokenKey),
                    let accessTokenExpirationDateString = try keychain.get(accessTokenExpirationDateKey),
                    let accessTokenExpirationDateDouble = Double(accessTokenExpirationDateString),
                    let refreshToken = try keychain.get(refreshTokenKey),
                    let refreshTokenExpirationDateString = try keychain.get(refreshTokenExpirationDateKey),
                    let refreshTokenExpirationDateDouble = Double(refreshTokenExpirationDateString) {
                    cachedTokens = OAuthTokens(accessToken: accessToken,
                                               accessTokenExpirationDate: Date(timeIntervalSinceReferenceDate: accessTokenExpirationDateDouble),
                                               refreshToken: refreshToken,
                                               refreshTokenExpirationDate: Date(timeIntervalSinceReferenceDate: refreshTokenExpirationDateDouble))
                }
            } catch let error {
                SDKLogger.error("Failed to get authentication information with error", error: error)
            }
            return cachedTokens
        }
        set {
            cachedTokens = newValue
            do {
                if let newValue = newValue {
                    try keychain.set(newValue.accessToken, key: accessTokenKey)
                    try keychain.set(String(newValue.accessTokenExpirationDate.timeIntervalSinceReferenceDate), key: accessTokenExpirationDateKey)
                    try keychain.set(newValue.refreshToken, key: refreshTokenKey)
                    try keychain.set(String(newValue.refreshTokenExpirationDate.timeIntervalSinceReferenceDate), key: refreshTokenExpirationDateKey)
                } else {
                    try keychain.remove(accessTokenKey)
                    try keychain.remove(accessTokenExpirationDateKey)
                    try keychain.remove(refreshTokenKey)
                    try keychain.remove(refreshTokenExpirationDateKey)
                }
            } catch let error {
                SDKLogger.error("Failed to save authentication information with error", error: error)
            }
        }
    }
}
