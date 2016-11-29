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
import XCTest
@testable import SparkSDK

fileprivate class MockStorage: OAuthStorage {
    var authenticationInfo: OAuthAuthenticationInfo?
}

fileprivate class MockOAuthClient: OAuthClient {
    var refreshOAuthAccessTokenFromRefreshToken_refreshToken: String?
    var refreshOAuthAccessTokenFromRefreshToken_clientAccount: ClientAccount?
    var refreshOAuthAccessTokenFromRefreshToken_completionHandler: ObjectHandler?
    var refreshOAuthAccessTokenFromRefreshToken_callCount = 0
    
    override func refreshOAuthAccessTokenFromRefreshToken(_ refreshToken: String, _ clientAccount: ClientAccount, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        refreshOAuthAccessTokenFromRefreshToken_refreshToken = refreshToken
        refreshOAuthAccessTokenFromRefreshToken_clientAccount = clientAccount
        refreshOAuthAccessTokenFromRefreshToken_completionHandler = completionHandler
        refreshOAuthAccessTokenFromRefreshToken_callCount = refreshOAuthAccessTokenFromRefreshToken_callCount + 1
    }
    
    override func fetchAccessTokenFromOAuthCode(_ code: String, _ clientAccount: ClientAccount, redirectUri: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        fatalError("unimplemented")
    }

    override func fetchAccessTokenFromOAuthCode(_ code: String, clientAccount: ClientAccount, redirectUri: String) throws -> AccessToken {
        fatalError("unimplemented")
    }
    
    override func refreshAccessTokenFromRefreshToken(_ refreshToken: String, clientAccount: ClientAccount) throws -> AccessToken {
        fatalError("unimplemented")
    }

}

class OAuthStrategyTests: XCTestCase {
    static let oneDay: TimeInterval = 24*60*60
    let yesterday = Date(timeIntervalSinceNow: -OAuthStrategyTests.oneDay)
    let tomorrow = Date(timeIntervalSinceNow: OAuthStrategyTests.oneDay)
    let now = Date()
    private var storage: MockStorage!
    private var oauthClient: MockOAuthClient!
    
    override func setUp() {
        storage = MockStorage()
        oauthClient = MockOAuthClient()
    }
    
    func testWhenRefreshTokenIsExpiredOrNotPresentThenAuthorizedIsFalse() {
        let testObject = createTestObject()
        
        XCTAssertFalse(testObject.authorized)
        
        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: yesterday)

        XCTAssertFalse(testObject.authorized)

        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)

        XCTAssertTrue(testObject.authorized)
    }

    func testWhenDeauthorizedThenAuthenticationInformationIsCleared() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        
        testObject.deauthorize()
        
        XCTAssertFalse(testObject.authorized)
        XCTAssertNil(storage.authenticationInfo)
    }
    
    func testWhenAccessTokenIsValidThenItIsImmediatelyReturned() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: tomorrow,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
        }
        
        XCTAssertEqual(retrievedAccessToken, "accessToken1")
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_callCount, 0)
    }
    
    func testWhenAccessTokenAndRefreshTokenAreExpiredThenNilIsImmediatelyReturnedForAccessToken() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: yesterday)
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        
        XCTAssertEqual(count, 1)
        XCTAssertNil(retrievedAccessToken)
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_callCount, 0)
    }
    
    func testWhenAccessTokenIsExpiredButRefreshTokenIsNotThenNewAccessTokenIsReturnedFromService() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        XCTAssertEqual(count, 0)
        
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_callCount, 1)
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_refreshToken, "refreshToken1")
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_clientAccount?.clientId, "clientId1")
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_clientAccount?.clientSecret, "clientSecret1")

        if let completionHandler = oauthClient.refreshOAuthAccessTokenFromRefreshToken_completionHandler {
            let accessTokenObject = AccessToken(accessToken: "accessToken2")
            accessTokenObject.accessTokenCreationDate = now
            accessTokenObject.accessTokenExpiration = OAuthStrategyTests.oneDay
            accessTokenObject.refreshTokenString = "refreshToken1"
            accessTokenObject.refreshTokenExpiration = 2 * OAuthStrategyTests.oneDay
            completionHandler(ServiceResponse<AccessToken>(nil, Result.success(accessTokenObject)))
        }

        XCTAssertEqual(retrievedAccessToken, "accessToken2")
        XCTAssertEqual(count, 1)
        
        let authInfo = storage.authenticationInfo
        XCTAssertEqual(authInfo?.accessToken, "accessToken2")
        XCTAssertEqualWithAccuracy(authInfo?.accessTokenExpirationDate.timeIntervalSinceReferenceDate ?? 0, tomorrow.timeIntervalSinceReferenceDate, accuracy: 1.0)
        XCTAssertEqual(authInfo?.refreshToken, "refreshToken1")
        let dayAfterTomorrow = Date(timeInterval: OAuthStrategyTests.oneDay, since: tomorrow)
        XCTAssertEqualWithAccuracy(authInfo?.refreshTokenExpirationDate.timeIntervalSinceReferenceDate ?? 0, dayAfterTomorrow.timeIntervalSinceReferenceDate, accuracy: 1.0)
    }
    
    func testWhenAccessTokenIsAlmostExpiredButRefreshTokenIsNotThenNewAccessTokenIsReturnedFromService() {
        let testObject = createTestObject()
        
        let almostExpired = now.addingTimeInterval(14*60)
        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: almostExpired,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        testObject.accessToken() { _ in
        }

        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_callCount, 1)
    }
    
    func testWhenAccessTokenRefreshFailsThenDeauthorized() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = OAuthAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                                             refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        
        if let completionHandler = oauthClient.refreshOAuthAccessTokenFromRefreshToken_completionHandler {
            let error = NSError()
            completionHandler(ServiceResponse<AccessToken>(nil, Result.failure(error)))
        }
        
        XCTAssertEqual(retrievedAccessToken, nil)
        XCTAssertNil(storage.authenticationInfo)
        XCTAssertEqual(count, 1)
    }
    
    private func createTestObject() -> OAuthStrategy {
        let clientAccount = ClientAccount(clientId: "clientId1", clientSecret: "clientSecret1")
        return OAuthStrategy(clientAccount: clientAccount, scope: "scope1", redirectUri: "https://example.com/oauth", storage: storage, oauthClient: oauthClient)
    }
}
