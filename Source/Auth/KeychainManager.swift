//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import KeychainAccess

struct KeychainManager {
    static let sharedInstance = KeychainManager()
    
    private let AccessTokenKey = "SparkSDK.AccessToken"
    private let ClientAccountKey = "SparkSDK.ClientAccount"
    
    
    // MARK:- ClientAccount API
    
    func fetchClientAccount() -> ClientAccount? {
        if let data = fetchDataWithKey(ClientAccountKey) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? ClientAccount
        }
        
        return nil
    }
    
    func storeClientAccount(clientAccount: ClientAccount?) {
        if clientAccount == nil {
            removeData(ClientAccountKey)
        } else {
            let data = NSKeyedArchiver.archivedDataWithRootObject(clientAccount!)
            storeDataWithKey(ClientAccountKey, data: data)
        }
    }
    
    // MARK:- AccessToken API
    
    func fetchAccessToken() -> AccessToken? {
        if let data = fetchDataWithKey(AccessTokenKey) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? AccessToken
        }
        
        return nil
    }

    func storeAccessToken(accessToken: AccessToken?) {
        if accessToken == nil {
            removeData(AccessTokenKey)
        } else {
            let data = NSKeyedArchiver.archivedDataWithRootObject(accessToken!)
            storeDataWithKey(AccessTokenKey, data: data)
        }
    }
    
    // MARK:- Common utility API
    private func removeData(key: String) {
        let keychain = getKeychainWithKey(key)
        do {
            try keychain.remove(key)
        } catch let error {
            print("removeDataFromKeychain error: \(error)")
        }
    }
    
    private func fetchDataWithKey(key: String) -> NSData? {
        let keychain = getKeychainWithKey(key)
        var data: NSData?
        do {
            try data = keychain.getData(key)
        } catch let error {
            print("fetchDataFromKeychain error: \(error)")
        }
        return data
    }
    
    private func storeDataWithKey(key: String, data: NSData) {
        let keychain = getKeychainWithKey(key)
        keychain[data: key] = data
    }
    
    private func getKeychainWithKey(key: String) -> Keychain {
        let service = getKeychainServiceWithKey(key)
        return Keychain(service: service)
    }
    
    private func getKeychainServiceWithKey(key: String) -> String {
        let bundleId = NSBundle.mainBundle().bundleIdentifier ?? ""
        return "\(bundleId).\(key)"
    }
}
