// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
            Logger.error("Failed to remove data with error: \(error)")
        }
    }
    
    private func fetchDataWithKey(key: String) -> NSData? {
        let keychain = getKeychainWithKey(key)
        var data: NSData?
        do {
            try data = keychain.getData(key)
        } catch let error {
            Logger.error("Failed to fetch data with error: \(error)")
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
