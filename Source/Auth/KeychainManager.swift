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

struct KeychainManager {
    static let sharedInstance = KeychainManager()
    
    fileprivate let AccessTokenKey = "SparkSDK.AccessToken"
    fileprivate let ClientAccountKey = "SparkSDK.ClientAccount"
    
    
    // MARK:- ClientAccount API
    
    func fetchClientAccount() -> ClientAccount? {
        if let data = fetchDataWithKey(ClientAccountKey) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? ClientAccount
        }
        
        return nil
    }
    
    func storeClientAccount(_ clientAccount: ClientAccount?) {
        if clientAccount == nil {
            removeData(ClientAccountKey)
        } else {
            let data = NSKeyedArchiver.archivedData(withRootObject: clientAccount!)
            storeDataWithKey(ClientAccountKey, data: data)
        }
    }
    
    // MARK:- AccessToken API
    
    func fetchAccessToken() -> AccessToken? {
        if let data = fetchDataWithKey(AccessTokenKey) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? AccessToken
        }
        
        return nil
    }

    func storeAccessToken(_ accessToken: AccessToken?) {
        if accessToken == nil {
            removeData(AccessTokenKey)
        } else {
            let data = NSKeyedArchiver.archivedData(withRootObject: accessToken!)
            storeDataWithKey(AccessTokenKey, data: data)
        }
    }
    
    // MARK:- Common utility API
    fileprivate func removeData(_ key: String) {
        let keychain = getKeychainWithKey(key)
        do {
            try keychain.remove(key)
        } catch let error {
            Logger.error("Failed to remove data with error: \(error)")
        }
    }
    
    fileprivate func fetchDataWithKey(_ key: String) -> Data? {
        let keychain = getKeychainWithKey(key)
        var data: Data?
        do {
            try data = keychain.getData(key)
        } catch let error {
            Logger.error("Failed to fetch data with error: \(error)")
        }
        return data
    }
    
    fileprivate func storeDataWithKey(_ key: String, data: Data) {
        let keychain = getKeychainWithKey(key)
        keychain[data: key] = data
    }
    
    fileprivate func getKeychainWithKey(_ key: String) -> Keychain {
        let service = getKeychainServiceWithKey(key)
        return Keychain(service: service)
    }
    
    fileprivate func getKeychainServiceWithKey(_ key: String) -> String {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        return "\(bundleId).\(key)"
    }
}
