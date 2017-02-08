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
import Alamofire
import SwiftyJSON
import SparkSDK
import XCTest
@testable import SparkSDK

struct TestUser {
    let accessToken: String
    let email: EmailAddress
    let name: String
    let orgId: String
    let personId: String
}

class SparkTestFixture {
    static let sharedInstance = SparkTestFixture()
    
    private let adminClientId: String
    private let adminClientSecret: String
    private let adminAccessToken: String
    let selfUser: TestUser
    let spark: Spark
    
    private init?() {
        guard let adminClientSecretValue = ProcessInfo().environment["CLIENTSECRET"] else { // check , !adminClientSecretValue.isEmpty()
            print("Failed to get client secret from CLIENTSECRET environment variable")
            return nil
        }
        adminClientId = "Cc5ce08d6eb24526c2af47c8ad39e58db1e07d3c53cbd4c9d359a5c471344c2fb"
        adminClientSecret = adminClientSecretValue
        guard let adminAccessTokenValue = SparkTestFixture.createAdminAccessToken(clientId: adminClientId, clientSecret: adminClientSecret) else {
            print("Failed to create admin access token")
            return nil
        }
        adminAccessToken = adminAccessTokenValue
        guard let selfUserValue = SparkTestFixture.createUser(adminAccessToken: adminAccessToken, adminClientId: adminClientId, adminClientSecret: adminClientSecret) else {
            print("Could not create initial user")
            return nil
        }
        selfUser = selfUserValue
        class Auth: AuthenticationStrategy {
            private let accessToken: String
            let authorized = true
            
            init(accessToken: String) {
                self.accessToken = accessToken
            }
            
            func deauthorize() {
            }
            
            func accessToken(completionHandler: @escaping (String?) -> Void) {
                completionHandler(accessToken)
            }
        }
        spark = Spark(authenticationStrategy: SimpleAuthStrategy(accessToken: selfUser.accessToken))
    }
    
    private static func createAdminAccessToken(clientId: String, clientSecret: String) -> String? {
        let adminCredentials: String = "\(clientId):\(clientSecret)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
        
        let accessTokenUrl = "https://idbroker.webex.com/idb/oauth2/v1/access_token"
        let headers = ["Authorization": "Basic \(adminCredentials)"]
        let body = ["grant_type": "client_credentials",
                    "scope": "webexsquare:admin Identity:SCIM"]
        var adminAccessTokenResult: String?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "create-token-queue")
        Alamofire.request(accessTokenUrl, method: .post, parameters: body, headers: headers).responseJSON(queue: queue) { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    adminAccessTokenResult = json["access_token"].stringValue
                }
            case .failure(let error):
                print(error)
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + .seconds(60))
        return adminAccessTokenResult
    }
    
    private static func createUser(adminAccessToken: String, adminClientId: String, adminClientSecret: String) -> TestUser? {
        let testUserUrl = "https://conv-a.wbx2.com/conversation/api/v1/users/test_users_s"
        let entitlements = ["spark", "webExSquared", "squaredCallInitiation", "squaredTeamMember", "squaredRoomModeration"]
        let scopes = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write spark:teams_write spark:teams_read spark:team_memberships_write spark:team_memberships_read"
        let userName = NSUUID().uuidString
        let email = userName + "@squared.example.com"
        let headers = ["Authorization": "Bearer \(adminAccessToken)",
                       "Content-Type": "application/json"]
        
        let body: [String: Any] = ["clientId": adminClientId,
                                   "clientSecret": adminClientSecret,
                                   "emailTemplate": email,
                                   "displayName": userName,
                                   "password": "P@ssw0rd123",
                                   "entitlements": entitlements,
                                   "authCodeOnly": "false",
                                   "scopes": scopes]
        var user: TestUser?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "create-user-queue")
        Alamofire.request(testUserUrl, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON(queue: queue) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let token = json["token"]["access_token"].string,
                    let userId = json["user"]["id"].string,
                    let email = EmailAddress.fromString(json["user"]["email"].stringValue),
                    let name = json["user"]["name"].string,
                    let orgId = json["user"]["orgId"].string {
                    let personId = SparkTestFixture.getPersonIdFromUserId(id: userId)
                    user = TestUser(accessToken: token, email: email, name: name, orgId: orgId, personId: personId)
                }
            case .failure(let error):
                print(error)
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + .seconds(60))
        return user
    }
    
    private static func getPersonIdFromUserId(id: String) -> String {
        let utf8 = "ciscospark://us/PEOPLE/" + id
        let data = utf8.data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: [])
        return base64.replacingOccurrences(of: "=", with: "")
    }
    
    @discardableResult
    func createUser() -> TestUser? {
        return SparkTestFixture.createUser(adminAccessToken: adminAccessToken, adminClientId: adminClientId, adminClientSecret: adminClientSecret)
    }
    
    @discardableResult
    func createRoom(testCase: XCTestCase, title: String) -> Room? {
        let request = { (completionHandler: @escaping (ServiceResponse<Room>) -> Void) in
            self.spark.rooms.create(title: title, completionHandler: completionHandler)
        }
        return getResponse(testCase: testCase, request: request)
    }
    
    @discardableResult
    func deleteRoom(testCase: XCTestCase, roomId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Any>) -> Void) in
            self.spark.rooms.delete(roomId: roomId, completionHandler: completionHandler)
        }
        return getResponse(testCase: testCase, request: request) != nil
    }
    
    func getResponse<T>(testCase: XCTestCase, request: @escaping (_ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) -> T? {
        let expect = testCase.expectation(description: "Service call")
        var output: T?
        request() { response in
            switch(response.result) {
            case .success(let result):
                output = result
            case .failure(_):
                output = nil
            }
            expect.fulfill()
        }
        testCase.waitForExpectations(timeout: 30) { error in XCTAssertNil(error, "Timeout") }
        return output
    }
    
    @discardableResult
    func createTeam(testCase: XCTestCase, teamName: String) -> Team? {
        let request = { (completionHandler: @escaping (ServiceResponse<Team>) -> Void) in
            self.spark.teams.create(name: teamName, completionHandler: completionHandler)
        }
        return getResponse(testCase: testCase, request: request)
    }
    
    @discardableResult
    func deleteTeam(testCase: XCTestCase, teamId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Any>) -> Void) in
            self.spark.teams.delete(teamId: teamId, completionHandler: completionHandler)
        }
        return getResponse(testCase: testCase, request: request) == nil ? false : true
    }
}
