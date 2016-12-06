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


class SparkInstance {
    
    private static var actualSharedInstance: SparkInstance?
    
    private static let clientIdKey = "clientIdKey"
    private static let clientSecretKey = "clientSecretKey"
    private static let scopeKey = "scopeKey"
    private static let redirectUriKey = "redirectUriKey"
    private static let simpleAccessTokenKey = "simpleAccessTokenKey"
    
    static var sharedInstance: SparkInstance {
        if actualSharedInstance == nil {
            Logger.warn("Detected use of deprecated SparkSDK API.")
            let actualSharedInstance = SparkInstance()
   
            let keychain = getKeychain()
            do {
                if let clientId = try keychain.get(clientIdKey),
                    let clientSecret = try keychain.get(clientSecretKey),
                    let scope = try keychain.get(scopeKey),
                    let redirectUri = try keychain.get(redirectUriKey) {
                    let clientAccount = ClientAccount(clientId: clientId, clientSecret: clientSecret)
                    let oauthStrategy = OAuthStrategy(clientAccount: clientAccount, scope: scope, redirectUri: redirectUri)
                    actualSharedInstance.set(authenticationStrategy: oauthStrategy)
                } else if let simpleAccessToken = try keychain.get(simpleAccessTokenKey) {
                    actualSharedInstance.set(authenticationStrategy: SimpleAuthStrategy(accessToken: simpleAccessToken))
                }
            } catch let error {
                Logger.error("Failed to get global authentication strategy information", error: error)
            }
            
            self.actualSharedInstance = actualSharedInstance
        }
        return actualSharedInstance!
    }
    
    static func saveGlobalOAuth(clientId: String, clientSecret: String, scope: String, redirectUri: String) {
        clearGlobalAuthenticationStrategyInformation()
        let keychain = getKeychain()
        do {
            try keychain.set(clientId, key: clientIdKey)
            try keychain.set(clientSecret, key: clientSecretKey)
            try keychain.set(scope, key: scopeKey)
            try keychain.set(redirectUri, key: redirectUriKey)
        } catch let error {
            Logger.error("Failed to save global OAuth information", error: error)
        }
    }
    
    static func saveGlobalSimpleAccessToken(_ simpleAccessToken: String) {
        clearGlobalAuthenticationStrategyInformation()
        let keychain = getKeychain()
        do {
            try keychain.set(simpleAccessToken, key: simpleAccessTokenKey)
        } catch let error {
            Logger.error("Failed to save global simple access token", error: error)
        }
    }
    
    static func clearGlobalAuthenticationStrategyInformation() {
        let keychain = getKeychain()
        do {
            try keychain.remove(clientIdKey)
            try keychain.remove(clientSecretKey)
            try keychain.remove(scopeKey)
            try keychain.remove(redirectUriKey)
            try keychain.remove(simpleAccessTokenKey)
        } catch let error {
            Logger.error("Failed to clear global authentication strategy information", error: error)
        }
    }
    
    private static func getKeychain() -> Keychain {
        return Keychain(service: "\(Bundle.main.bundleIdentifier ?? "").sparksdk.deprecated.global")
    }

    
    let authenticationStrategy: AuthenticationStrategyProxy
    let phone: Phone
    let callManager: CallManager
    
    init() {
        authenticationStrategy = AuthenticationStrategyProxy()
        let deviceService = DeviceService(authenticationStrategy: authenticationStrategy)
        callManager = CallManager(authenticationStrategy: authenticationStrategy, deviceService: deviceService)
        let webSocketService = WebSocketService(authenticationStrategy: authenticationStrategy, callManager: callManager)
        let applicationLifecycleObserver = ApplicationLifecycleObserver(webSocketService: webSocketService, callManager: callManager, deviceService: deviceService)
        phone = Phone(authenticationStrategy: authenticationStrategy, applicationLifecycleObserver: applicationLifecycleObserver, webSocketService: webSocketService, callManager: callManager, deviceService: deviceService)
    }
    
    func set(authenticationStrategy: AuthenticationStrategy) {
        self.authenticationStrategy.setDelegateStrategy(authenticationStrategy)
    }
}
