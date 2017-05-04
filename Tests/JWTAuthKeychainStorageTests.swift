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
import KeychainAccess
import XCTest
@testable import SparkSDK


class JWTAuthKeychainStorageTests: XCTestCase {
    private var keychain: MockKeychain!
    
    override func setUp() {
        keychain = MockKeychain()
    } 
    
    private func createTestObject() -> JWTAuthStorage {
        return JWTAuthKeychainStorage(keychain: keychain)
    }
    
    func testWhenLoginInformationIsSavedAuthInfoCanBeRetrieved() {
        let info = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: Date(timeIntervalSince1970: 1))
        let testObject1 = createTestObject()
        testObject1.authenticationInfo = info
        XCTAssertTrue(auth(testObject1.authenticationInfo, isEqualTo: info))
        
        let testObject2 = createTestObject()
        XCTAssertTrue(auth(testObject2.authenticationInfo, isEqualTo: info))
    }
    
    func testWhenLoginInformationIsClearedThenAuthStorageIsEmpty() {
        let info = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: Date(timeIntervalSince1970: 1))
        let testObject1 = createTestObject()
        testObject1.authenticationInfo = info
        _ = testObject1.authenticationInfo
        testObject1.authenticationInfo = nil
        
        let testObject2 = createTestObject()
        XCTAssertNil(testObject2.authenticationInfo)
    }
    
    func testWhenJWTIsStoredThenJWTCanBeRetrievedFromStorage() {
        let testObject1 = createTestObject()
        testObject1.jwt = "jwt1"
        XCTAssertEqual(testObject1.jwt, "jwt1")
        
        let testObject2 = createTestObject()
        XCTAssertEqual(testObject2.jwt, "jwt1")
    }
    
    func testWhenJWTIsClearedThenJWTStorageIsEmpty() {
        let testObject1 = createTestObject()
        testObject1.jwt = "jwt1"
        
        testObject1.jwt = nil
        XCTAssertNil(testObject1.jwt)
        
        let testObject2 = createTestObject()
        XCTAssertNil(testObject2.jwt)
    }
    
    private func auth(_ first: JWTAuthenticationInfo?, isEqualTo second: JWTAuthenticationInfo?) -> Bool {
        guard let first = first, let second = second else {
            return false
        }
        return first.accessToken == second.accessToken && first.accessTokenExpirationDate == second.accessTokenExpirationDate
    }
}
