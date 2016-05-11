//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import KeychainAccess

class KeychainUtil {
    static let AccessTokenKey = "SparkSDK.AccessToken"
    
    static func keychainServiceOfToken() -> String {
        let bundleId = NSBundle.mainBundle().bundleIdentifier ?? ""
        return "\(bundleId).SparkSDK.AccessToken"
    }
    
    static func fetchTokenDataFromKeychain() -> NSData? {
        let keychain = Keychain(service: keychainServiceOfToken())
        var accessToken: NSData?
        do {
            try accessToken = keychain.getData(AccessTokenKey)
        } catch let error {
            print("keychain.getData error: \(error)")
        }
        return accessToken
    }
    
    static func storeTokenDataInKeychain(data: NSData) {
        let keychain = Keychain(service: keychainServiceOfToken())
        keychain[data: AccessTokenKey] = data
    }
    
    static func removeAccessTokenFromKeychain() {
        let keychain = Keychain(service: keychainServiceOfToken())
        do {
            try keychain.remove(AccessTokenKey)
        } catch let error {
            print("removeAccessTokenFromKeychain error: \(error)")
        }
    }
}
