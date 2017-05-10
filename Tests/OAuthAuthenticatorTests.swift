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
import XCTest
@testable import SparkSDK

fileprivate class MockStorage: OAuthStorage {
    var tokens: OAuthTokens?
}

fileprivate class MockOAuthClient: OAuthClient {
    var refreshOAuthAccessTokenFromRefreshToken_refreshToken: String?
    var refreshOAuthAccessTokenFromRefreshToken_clientId: String?
    var refreshOAuthAccessTokenFromRefreshToken_clientSecret: String?
    var refreshOAuthAccessTokenFromRefreshToken_completionHandler: ObjectHandler?
    var refreshOAuthAccessTokenFromRefreshToken_callCount = 0
    
    var fetchAccessTokenFromOAuthCode_oauthCode: String?
    var fetchAccessTokenFromOAuthCode_clientId: String?
    var fetchAccessTokenFromOAuthCode_clientSecret: String?
    var fetchAccessTokenFromOAuthCode_redirectUri: String?
    var fetchAccessTokenFromOAuthCode_completionHandler: ObjectHandler?
    var fetchAccessTokenFromOAuthCode_callCount = 0
    
    override func refreshAccessTokenFrom(refreshToken: String, clientId: String, clientSecret: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        refreshOAuthAccessTokenFromRefreshToken_refreshToken = refreshToken
        refreshOAuthAccessTokenFromRefreshToken_clientId = clientId
        refreshOAuthAccessTokenFromRefreshToken_clientSecret = clientSecret
        refreshOAuthAccessTokenFromRefreshToken_completionHandler = completionHandler
        refreshOAuthAccessTokenFromRefreshToken_callCount += 1
    }
    
    override func fetchAccessTokenFrom(oauthCode: String, clientId: String, clientSecret: String, redirectUri: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        fetchAccessTokenFromOAuthCode_oauthCode = oauthCode
        fetchAccessTokenFromOAuthCode_clientId = clientId
        fetchAccessTokenFromOAuthCode_clientSecret = clientSecret
        fetchAccessTokenFromOAuthCode_redirectUri = redirectUri
        fetchAccessTokenFromOAuthCode_completionHandler = completionHandler
        fetchAccessTokenFromOAuthCode_callCount += 1
    }
}

fileprivate class MockOAuthLauncher: OAuthLauncher {
    var parentViewController: UIViewController?
    var authorizationUrl: URL?
    var redirectUri: String?
    var completionHandler: ((String?) -> Void)?
    var callCount = 0
    
    override func launchOAuthViewController(parentViewController: UIViewController, authorizationUrl: URL,
                                            redirectUri: String, completionHandler: @escaping (String?) -> Void) {
        self.parentViewController = parentViewController
        self.authorizationUrl = authorizationUrl
        self.redirectUri = redirectUri
        self.completionHandler = completionHandler
        callCount += 1
    }
}

fileprivate class MockDelegate: OAuthAuthenticatorDelegate {
    var callCount = 0
    
    func refreshAccessTokenFailed() {
        callCount += 1
    }
}

class OAuthAuthenticatorTests: XCTestCase {
    var oneDay: TimeInterval = 24 * 60 * 60
    var yesterday: Date!
    var tomorrow: Date!
    var parent = UIViewController()
    private var storage: MockStorage!
    private var oauthClient: MockOAuthClient!
    private var oauthLauncher: MockOAuthLauncher!
    private var clock: MockClock!
    private var delegate: MockDelegate!
    
    override func setUp() {
        clock = MockClock()
        clock.currentTime = Date(timeIntervalSinceReferenceDate: 10000)
        yesterday = Date(timeInterval: -oneDay, since: clock.currentTime)
        tomorrow = Date(timeInterval: oneDay, since: clock.currentTime)
        
        storage = MockStorage()
        oauthClient = MockOAuthClient()
        oauthLauncher = MockOAuthLauncher()
        delegate = MockDelegate()
    }
    
    func testWhenRefreshTokenIsExpiredOrNotPresentThenAuthorizedIsFalse() {
        let testObject = createTestObject()
        
        XCTAssertFalse(testObject.authorized)
        
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                     refreshToken: "refreshToken1", refreshTokenExpirationDate: yesterday)
        
        XCTAssertFalse(testObject.authorized)
        
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                     refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        
        XCTAssertTrue(testObject.authorized)
    }
    
    func testWhenDeauthorizedThenAuthenticationInformationIsCleared() {
        let testObject = createTestObject()
        
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                     refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        
        testObject.deauthorize()
        
        XCTAssertFalse(testObject.authorized)
        XCTAssertNil(storage.tokens)
    }
    
    func testWhenAccessTokenIsValidThenItIsImmediatelyReturned() {
        let testObject = createTestObject()
        
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: tomorrow,
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
        
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
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
        
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
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
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_clientId, "clientId1")
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_clientSecret, "clientSecret1")
        
        let response = accessTokenResponse(accessToken: "accessToken2", accessExpiration: oneDay, refreshToken: "refreshToken1", refreshExpiration: 2 * oneDay)
        oauthClient.refreshOAuthAccessTokenFromRefreshToken_completionHandler?(response)
        
        XCTAssertEqual(retrievedAccessToken, "accessToken2")
        XCTAssertEqual(count, 1)
        
        let authInfo = storage.tokens
        XCTAssertEqual(authInfo?.accessToken, "accessToken2")
        XCTAssertEqualWithAccuracy(authInfo?.accessTokenExpirationDate.timeIntervalSinceReferenceDate ?? 0, tomorrow.timeIntervalSinceReferenceDate, accuracy: 1.0)
        XCTAssertEqual(authInfo?.refreshToken, "refreshToken1")
        let dayAfterTomorrow = Date(timeInterval: oneDay, since: tomorrow)
        XCTAssertEqualWithAccuracy(authInfo?.refreshTokenExpirationDate.timeIntervalSinceReferenceDate ?? 0, dayAfterTomorrow.timeIntervalSinceReferenceDate, accuracy: 1.0)
        XCTAssertEqual(delegate.callCount, 0)
    }
    
    func testWhenAccessTokenIsAlmostExpiredButRefreshTokenIsNotThenNewAccessTokenIsReturnedFromService() {
        let testObject = createTestObject()
        
        let almostExpired = clock.currentTime.addingTimeInterval(14*60)
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: almostExpired,
                                     refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        testObject.accessToken() { _ in
        }
        
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_callCount, 1)
    }
    
    func testWhenAccessTokenRefreshFailsThenDeauthorized() {
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday,
                                     refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        let testObject = createTestObject()
        
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        XCTAssertEqual(delegate.callCount, 0)
        
        oauthClient.refreshOAuthAccessTokenFromRefreshToken_completionHandler?(ServiceResponse<OAuthTokenModel>(nil, Result.failure(SparkError.illegalStatus(reason: "Fetch fails test"))))
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(retrievedAccessToken, nil)
        XCTAssertNil(storage.tokens)
        XCTAssertEqual(delegate.callCount, 1)
        XCTAssertFalse(testObject.authorized)
    }
    
    func testWhenAuthorizationIsStartedThenAuthorizationLauncherIsCorrectlyLaunched() {
        let testObject = createTestObject(clientId: "client id1?", scope: "scope : 1",
                                          redirectUri: "https://example.com/o%20auth?final=true")
        
        testObject.authorize(parentViewController: parent) { _ in }
        
        XCTAssertEqual(oauthLauncher.callCount, 1)
        XCTAssertEqual(oauthLauncher.parentViewController, parent)
        XCTAssertEqual(oauthLauncher.authorizationUrl?.scheme, "https")
        XCTAssertEqual(oauthLauncher.authorizationUrl?.host, "api.ciscospark.com")
        XCTAssertEqual(oauthLauncher.authorizationUrl?.path, "/v1/authorize")
        let parameters = oauthLauncher.authorizationUrl?.queryParameters
        XCTAssertEqual(parameters?["client_id"], "client+id1%3F")
        XCTAssertEqual(parameters?["response_type"], "code")
        XCTAssertEqual(parameters?["redirect_uri"], "https%3A%2F%2Fexample.com%2Fo%2520auth%3Ffinal%3Dtrue")
        XCTAssertEqual(parameters?["scope"], "scope+%3A+1")
        XCTAssertNotNil(parameters?["state"])
        XCTAssertEqual(oauthLauncher.redirectUri, "https://example.com/o%20auth?final=true")
    }
    
    func testWhenAuthorizationIsStartedAndIsSuccessfulThenAuthenticationInformationIsRetrieved() {
        let testObject = createTestObject(redirectUri: "https://example.com/oauth")
        
        var successResult: Bool? = nil
        var count = 0
        testObject.authorize(parentViewController: parent) { success in
            successResult = success
            count += 1
        }
        XCTAssertEqual(count, 0)
        XCTAssertEqual(oauthClient.fetchAccessTokenFromOAuthCode_callCount, 0)
        
        oauthLauncher.completionHandler?("oauthCode1")
        
        XCTAssertEqual(oauthClient.fetchAccessTokenFromOAuthCode_callCount, 1)
        XCTAssertEqual(oauthClient.fetchAccessTokenFromOAuthCode_oauthCode, "oauthCode1")
        XCTAssertEqual(oauthClient.fetchAccessTokenFromOAuthCode_redirectUri, "https://example.com/oauth")
        XCTAssertEqual(oauthClient.fetchAccessTokenFromOAuthCode_clientId, "clientId1")
        XCTAssertEqual(oauthClient.fetchAccessTokenFromOAuthCode_clientSecret, "clientSecret1")
        
        oauthClient.fetchAccessTokenFromOAuthCode_completionHandler?(accessTokenResponse())
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(successResult, true)
    }
    
    func testWhenAuthorizationIsStartedAndIsSuccessfulThenWeHaveAccessAndTokenExists() {
        let testObject = createTestObject()
        
        testObject.authorize(parentViewController: parent)
        XCTAssertFalse(testObject.authorized)
        
        oauthLauncher.completionHandler?("oauthCode1")
        let response = accessTokenResponse(accessToken: "accessToken1")
        oauthClient.fetchAccessTokenFromOAuthCode_completionHandler?(response)
        
        XCTAssertTrue(testObject.authorized)
        var accessToken: String? = nil
        testObject.accessToken { retrievedAccessToken in
            accessToken = retrievedAccessToken
        }
        XCTAssertEqual(accessToken, "accessToken1")
        XCTAssertEqual(storage.tokens?.accessToken, "accessToken1")
        XCTAssertEqual(storage.tokens?.accessTokenExpirationDate, tomorrow)
        XCTAssertEqual(storage.tokens?.refreshToken, "refreshToken1")
        XCTAssertEqual(storage.tokens?.refreshTokenExpirationDate, tomorrow)
    }
    
    func testWhenAuthorizationIsStartedAndCancelledThenAuthenticationFails() {
        let testObject = createTestObject()
        
        var successResult: Bool? = nil
        var count = 0
        testObject.authorize(parentViewController: parent) { success in
            successResult = success
            count += 1
        }
        XCTAssertEqual(count, 0)
        
        oauthLauncher.completionHandler?(nil)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(successResult, false)
        XCTAssertEqual(oauthClient.fetchAccessTokenFromOAuthCode_callCount, 0)
        XCTAssertFalse(testObject.authorized)
    }
    
    func testWhenAccessTokenCallFailsWhenGettingAccessTokenFromOAuthCodeThenNoLongerAuthorized() {
        let testObject = createTestObject()
        
        testObject.authorize(parentViewController: parent)
        
        oauthLauncher.completionHandler?("oauthCode1")
        
        let response = ServiceResponse<OAuthTokenModel>(nil, Result.failure(SparkError.illegalStatus(reason: "Getting fails test")))
        oauthClient.fetchAccessTokenFromOAuthCode_completionHandler?(response)
        
        XCTAssertFalse(testObject.authorized)
    }
    
    func testWhenIncompleteAuthenticationInfoIsReturnedFromClientThenNoLongerAuthorized() {
        let testObject = createTestObject()
        
        testObject.authorize(parentViewController: parent)
        
        oauthLauncher.completionHandler?("oauthCode1")
        let response = accessTokenResponse(accessToken: nil)
        oauthClient.fetchAccessTokenFromOAuthCode_completionHandler?(response)
        
        XCTAssertFalse(testObject.authorized)
    }
    
    func testWhenOAuthCodeIsReturnedThenImmediatelyAuthorized() {
        let testObject = createTestObject()
        
        var successResult: Bool? = nil
        var count = 0
        testObject.authorize(parentViewController: parent) { success in
            successResult = success
            count += 1
        }
        
        oauthLauncher.completionHandler?("oauthCode1")
        
        XCTAssertTrue(testObject.authorized)
        XCTAssertEqual(successResult, true)
        XCTAssertEqual(count, 1)
    }
    
    func testWhenProcessingOAuthCodeAndWeAskForATokenThenWeReturnTheCorrectToken() {
        let testObject = createTestObject()
        
        testObject.authorize(parentViewController: parent)
        oauthLauncher.completionHandler?("oauthCode1")
        
        var count = 0
        var savedToken: String? = nil
        
        testObject.accessToken() { token in
            count += 1
            savedToken = token
        }
        
        oauthClient.fetchAccessTokenFromOAuthCode_completionHandler?(accessTokenResponse(accessToken: "accessToken1"))
        
        XCTAssertEqual(savedToken, "accessToken1")
        XCTAssertEqual(count, 1)
    }
    
    func testWhenMultipleAccessTokensAreRequestedThenRefreshIsCalledOnceAndBothReturnAndTheDelegateIsOnlyNotifiedOnce() {
        let testObject = createTestObject()
        
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday, refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        
        var firstCount = 0
        testObject.accessToken() { accessToken in
            firstCount += 1
        }
        
        var secondCount = 0
        testObject.accessToken() { accessToken in
            secondCount += 1
        }
        
        XCTAssertEqual(delegate.callCount, 0)
        
        let error = SparkError.illegalStatus(reason: "Multiple request failed test")
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_callCount, 1)
        oauthClient.refreshOAuthAccessTokenFromRefreshToken_completionHandler?(ServiceResponse<OAuthTokenModel>(nil, Result.failure(error)))
        
        XCTAssertNil(storage.tokens)
        XCTAssertEqual(firstCount, 1)
        XCTAssertEqual(secondCount, 1)
        XCTAssertEqual(delegate.callCount, 1)
    }
    
    func testWhenAccessTokenExpiresASecondTimeThenItCanStillBeRetrieved() {
        storage.tokens = OAuthTokens(accessToken: "accessToken1", accessTokenExpirationDate: yesterday, refreshToken: "refreshToken1", refreshTokenExpirationDate: tomorrow)
        let testObject = createTestObject()
        testObject.accessToken() { _ in }
        oauthClient.refreshOAuthAccessTokenFromRefreshToken_completionHandler?(accessTokenResponse(accessToken: "accessToken2", refreshExpiration: 14 * oneDay))
        
        clock.advance(by: 2 * oneDay)
        
        var savedToken: String? = nil
        testObject.accessToken() { token in
            savedToken = token
        }
        
        XCTAssertEqual(oauthClient.refreshOAuthAccessTokenFromRefreshToken_callCount, 2)
        oauthClient.refreshOAuthAccessTokenFromRefreshToken_completionHandler?(accessTokenResponse(accessToken: "accessToken3"))
        
        XCTAssertEqual(savedToken, "accessToken3")
    }
    
    private func accessTokenResponse(accessToken: String? = "accessToken1",
                                     accessExpiration: TimeInterval? = nil,
                                     refreshToken: String? = "refreshToken1",
                                     refreshExpiration: TimeInterval? = nil) -> ServiceResponse<OAuthTokenModel> {
        var accessTokenObject = OAuthTokenModel(JSONString: "{}")!
        accessTokenObject.accessTokenString = accessToken
        accessTokenObject.accessTokenCreationDate = clock.currentTime
        accessTokenObject.accessTokenExpiration = accessExpiration ?? oneDay
        accessTokenObject.refreshTokenString = refreshToken
        accessTokenObject.refreshTokenExpiration = refreshExpiration ?? oneDay
        return ServiceResponse<OAuthTokenModel>(nil, Result.success(accessTokenObject))
    }
    
    private func createTestObject(clientId: String = "clientId1", scope: String = "scope1", redirectUri: String = "https://example.com/oauth") -> OAuthAuthenticator {
        let strategy = OAuthAuthenticator(clientId: clientId, clientSecret: "clientSecret1", scope: scope, redirectUri: redirectUri, storage: storage, oauthClient: oauthClient, oauthLauncher: oauthLauncher, clock: clock)
        strategy.delegate = delegate
        return strategy
    }
}
