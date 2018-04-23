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
import XCTest
@testable import SparkSDK


class OAuthKeychainStorageTests: XCTestCase {
    private var keychain: MockKeychain!
    
    override func setUp() {
        keychain = MockKeychain()
    }

    private func createTestObject() -> OAuthKeychainStorage {
        return OAuthKeychainStorage(keychain: keychain)
    }
    
    func testWhenLoginInformationIsSavedItCanBeRetrieved() {
        let info = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: Date(timeIntervalSince1970: 1),
                                           refreshToken: "refreshToken1", refreshTokenExpirationDate: Date(timeIntervalSinceReferenceDate: 2))
        let testObject1 = createTestObject()
        testObject1.tokens = info
        XCTAssertTrue(auth(testObject1.tokens, isEqualTo: info))
        
        let testObject2 = createTestObject()
        XCTAssertTrue(auth(testObject2.tokens, isEqualTo: info))
    }
    
    func testWhenLoginInformationIsClearedThenItIsNil() {
        let info = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: Date(timeIntervalSince1970: 1),
                                           refreshToken: "refreshToken1", refreshTokenExpirationDate: Date(timeIntervalSinceReferenceDate: 2))
        let testObject1 = createTestObject()
        testObject1.tokens = info
        _ = testObject1.tokens
        testObject1.tokens = nil
        
        let testObject2 = createTestObject()
        XCTAssertNil(testObject2.tokens)
    }
    
    private func auth(_ first: OAuthTokens?, isEqualTo second: OAuthTokens?) -> Bool {
        guard let first = first, let second = second else {
            return false
        }
        return first.accessToken == second.accessToken && first.accessTokenExpirationDate == second.accessTokenExpirationDate && first.refreshToken == second.refreshToken && first.refreshTokenExpirationDate == second.refreshTokenExpirationDate
    }
}
