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


fileprivate class MockJWTStorage: JWTAuthStorage {
    var jwt: String?
    var authenticationInfo: JWTAuthenticationInfo?
}

fileprivate class MockJWTClient: JWTAuthClient {
    var fetchTokenFromJWT_callCount = 0
    var fetchTokenFromJWT_completionHandler: ObjectHandler?
    
    override func fetchTokenFromJWT(_ jwt: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {   
        fetchTokenFromJWT_completionHandler = completionHandler
        fetchTokenFromJWT_callCount = fetchTokenFromJWT_callCount + 1
    }
}

class JWTAuthStrategyTests: XCTestCase {
    private static let oneDay: TimeInterval = 24*60*60
    private let yesterday = Date(timeIntervalSinceNow: -OAuthStrategyTests.oneDay)
    private let tomorrow = Date(timeIntervalSinceNow: OAuthStrategyTests.oneDay)
    private let now = Date()
    private var storage: MockJWTStorage!
    private var client: MockJWTClient!
    private static let testJWT = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJibGFoIiwiaXNzIjoidGhpc0lzQVRlc3QiLCJleHAiOjQxMDI0NDQ4MDB9.p4frHZUGx8Qi60P77fl09lKCRGoJFNZzUqBm2fKOfC4"
    private let expiredTestJWT = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJibGFoIiwiaXNzIjoidGhpc0lzQVRlc3QiLCJleHAiOjE0NTE2MDY0MDB9.qgOgOrakNKAgvBumc5qwbK_ypEAVRpKi7cZWev1unSY"
    private let jwtWithoutExpiration = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiaXNzIjoiaXNzMSJ9.AwLFa7xpba0YoWRYVqXdTUDSa9bvOA7H7tdmqh7zvlA"
    private let jwtWithTooManySegments = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiaXNzIjoiaXNzMSJ9.AwLFa7xpba0YoWRYVqXdTUDSa9bvOA7H7tdmqh7zvlA.AwLFa7xpba0YoWRYVqXdTUDSa9bvOA7H7tdmqh7zvlA" 
    private let jwtWithTooFewSegments = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiaXNzIjoiaXNzMSJ9"
    private let jwtWithBadData = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJZdWiIOLIx%jN9NTY3ODkwIiwiaXNzIjoiaXNzMSJ9.AwLFa7xpba0YoWRYVqXdTUDSa9bvOA7H7tdmqh7zvlA"
    
    override func setUp() {
        storage = MockJWTStorage()
        client = MockJWTClient()
    }
    
    func testWhenValidAccessTokenThenItIsImmediatelyReturned() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: tomorrow)
        
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
        }
        
        XCTAssertEqual(retrievedAccessToken, "accessToken1")
    }
    
    func testWhenAccessTokenExistsAndJWTIsExpiredThenNilIsImmediatelyReturnedForAccessToken() {
        let testObject = createTestObject(jwt: expiredTestJWT)

        storage.authenticationInfo = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday)
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        
        XCTAssertEqual(count, 1)
        XCTAssertNil(retrievedAccessToken)
        XCTAssertEqual(client.fetchTokenFromJWT_callCount, 0)
    }
    
    func testWhenAccessTokenExpiredButJWTIsValidThenAccessTokenIsRefreshed() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday)
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        XCTAssertEqual(count, 0)
        
        XCTAssertEqual(client.fetchTokenFromJWT_callCount, 1)
        
        let response = accessTokenResponse(accessToken: "accessToken2")
        client.fetchTokenFromJWT_completionHandler?(response)
        
        XCTAssertEqual(retrievedAccessToken, "accessToken2")
        XCTAssertEqual(count, 1)
        
        let authInfo = storage.authenticationInfo
        XCTAssertEqual(authInfo?.accessToken, "accessToken2")
        XCTAssertEqualWithAccuracy(authInfo?.accessTokenExpirationDate.timeIntervalSinceReferenceDate ?? 0, tomorrow.timeIntervalSinceReferenceDate, accuracy: 1.0)
    }
    
    func testWhenAccessTokenHasNoExpirationDateThenItIsAlwaysAuthorized() {
        let testObject = createTestObject(jwt: jwtWithoutExpiration)
        XCTAssertTrue(testObject.authorized)
        
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }

        XCTAssertEqual(client.fetchTokenFromJWT_callCount, 1)
        
        let response = accessTokenResponse(accessToken: "accessToken1")
        client.fetchTokenFromJWT_completionHandler?(response)
        
        XCTAssertEqual(retrievedAccessToken, "accessToken1")
        XCTAssertEqual(count, 1)
    }
    
    func testWhenAccessTokenFetchFailsThenDeauthorized() {
        let testObject = createTestObject()
        
        storage.authenticationInfo = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: yesterday)
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        
        client.fetchTokenFromJWT_completionHandler?(ServiceResponse<JWTAccessTokenCreationResult>(nil, Result.failure(NSError())))
        
        XCTAssertEqual(retrievedAccessToken, nil)
        XCTAssertNil(storage.authenticationInfo)
        XCTAssertEqual(count, 1)
    }
    
    func testWhenDeauthorizedThenAuthInfoIsCleared() {
        storage.authenticationInfo = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: tomorrow)
        let testObject = createTestObject()
        
        testObject.deauthorize()
        
        XCTAssertFalse(testObject.authorized)
        XCTAssertNil(storage.authenticationInfo)
    }
    
    func testWhenANewJwtIsSetThenANewAccessTokenIsRetrieved() {
        storage.authenticationInfo = JWTAuthenticationInfo(accessToken: "accessToken1", accessTokenExpirationDate: tomorrow)
        let testObject = createTestObject()

        testObject.authorizedWith(jwt: jwtWithoutExpiration)

        XCTAssertEqual(storage.jwt, jwtWithoutExpiration)
        
        var count = 0
        var retrievedAccessToken: String? = nil
        testObject.accessToken() { accessToken in
            retrievedAccessToken = accessToken
            count = count + 1
        }
        XCTAssertEqual(count, 0)
        
        client.fetchTokenFromJWT_completionHandler?(accessTokenResponse(accessToken: "accessToken2"))

        XCTAssertEqual(retrievedAccessToken, "accessToken2")
        XCTAssertEqual(count, 1)
    }
    
    func testWhenANewJwtIsSetButHasIncorrectSegmentsThenJwtIsNotAuthorized() {
        let testObject = createTestObject()
        testObject.authorizedWith(jwt: jwtWithTooManySegments)
        
        XCTAssertFalse(testObject.authorized)
        
        let testObject2 = createTestObject()
        testObject2.authorizedWith(jwt: jwtWithTooFewSegments)
        
        XCTAssertFalse(testObject2.authorized)
    }
    
    func testWhenANewJwtIsSetButHasUnparseableDataThenJwtIsNotAuthorized() {
        let testObject = createTestObject(jwt: jwtWithBadData)
        
        XCTAssertFalse(testObject.authorized)
    }
    
    private func createTestObject(jwt: String = testJWT) -> JWTAuthStrategy {
        let strategy = JWTAuthStrategy(storage: storage, client: client)
        strategy.authorizedWith(jwt: jwt)
        return strategy
    }
    
    private func accessTokenResponse(accessToken: String) -> ServiceResponse<JWTAccessTokenCreationResult> {
        let accessTokenObject = JWTAccessTokenCreationResult(token: accessToken)
        accessTokenObject.tokenCreationDate = now
        accessTokenObject.tokenExpiration = JWTAuthStrategyTests.oneDay
        return ServiceResponse<JWTAccessTokenCreationResult>(nil, Result.success(accessTokenObject))
    }
}
