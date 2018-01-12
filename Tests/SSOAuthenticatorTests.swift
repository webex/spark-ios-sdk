//
//  SSOAuthenticatorTests.swift
//  SparkSDK
//
//  Created by Rob Peek on 07/08/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import XCTest
@testable import SparkSDK

class SSOAuthenticatorTests: XCTestCase {
    
    var queryItems: [URLQueryItem] = []
    let email = "someuser@spark.id"
        
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAuthorizationUrlContainsEmail() {
        let testObject = createTestObject()
        let authorizationUrl = testObject.authorizationUrl()
        let encodeEmail = email.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        XCTAssert((authorizationUrl?.absoluteString.contains(encodeEmail!))!, "Overriden authorization url should contain email parameter")
    }
    
    func testAuthorizationUrlAcceptsAdditionalQueryItems() {
        
        let queryItem = URLQueryItem(name: "token", value:"sample_access_token")
        queryItems = [queryItem]
        
        let testObject = createTestObject()
        if let authorizationUrl = testObject.authorizationUrl() {
            XCTAssert(authorizationUrl.absoluteString.contains(queryItem.name), "Overriden authorization url should contain additional query item name")
            XCTAssert(authorizationUrl.absoluteString.contains(queryItem.value!), "Overriden authorization url should contain additional query item value")
        }
        
        
    }
    
    private func createTestObject(clientId: String = "clientId1", clientSecret: String = "clientSecret1", scope: String = "scope1", redirectUri: String = "https://example.com/oauth", identityProviderUri: String = "https://simple.identityprovider.example") -> SSOAuthenticator {
        return SSOAuthenticator(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri, email: email, identityProviderUri: identityProviderUri, queryItems: queryItems)
    }
    
}
