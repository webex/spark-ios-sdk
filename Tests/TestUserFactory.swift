//
//  TestUserFactory.swift
//  SparkSDK
//
//  Created by Bin Xu on 7/22/16.
//  Copyright © 2016 Cisco. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SparkSDK

struct TestUser {
    var id: String?
    var token: String?
    var email: EmailAddress?
    var name: String?
    var orgId: String?
    var personId: String?
}

class TestUserFactory {
    static let sharedInstance = TestUserFactory()
    
    private let testUserUrl = "https://conv-a.wbx2.com/conversation/api/v1/users/test_users_s"
    private let entitlements = ["spark", "webExSquared", "squaredCallInitiation", "squaredTeamMember", "squaredRoomModeration"]
    private let scopes = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write spark:teams_write spark:teams_read spark:team_memberships_write spark:team_memberships_read"
    
    private let token = AccessToken()
    private let client = Client()
    
    func createUser() -> TestUser {
        let userName = NSUUID().UUIDString
        let email = userName + "@squared.example.com"
        let headers = ["Authorization": "Bearer \(token.value)",
                       "Content-Type": "application/json"]
        
        let body: [String: AnyObject] = ["clientId": client.id,
                                         "clientSecret": client.secret,
                                         "emailTemplate": email,
                                         "displayName": userName,
                                         "password": "P@ssw0rd123",
                                         "entitlements": entitlements,
                                         "authCodeOnly": "false",
                                         "scopes": scopes]
        var user = TestUser()
        let semaphore = dispatch_semaphore_create(0)
        let queue = dispatch_queue_create("create-user-queue", nil)
        Alamofire.request(.POST, testUserUrl, parameters: body, encoding: .JSON, headers: headers)
            .responseJSON(queue: queue) { response in
                
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        user.token = json["token"]["access_token"].stringValue
                        user.id = json["user"]["id"].stringValue
                        user.email = EmailAddress.fromString(json["user"]["email"].stringValue)
                        user.name = json["user"]["name"].stringValue
                        user.orgId = json["user"]["orgId"].stringValue
                        user.personId = self.getPersonIdFromUserId(user.id!)
                        
                        dispatch_semaphore_signal(semaphore)
                    }
                case .Failure(let error):
                    print(error)
                    dispatch_semaphore_signal(semaphore)
                }
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return user
    }
    
    private func removePadding(base64: String) -> String {
        var result = base64
        if result.characters.last! == "=" {
            result = String(result.characters.dropLast())
            if result.characters.last! == "=" {
                result = String(result.characters.dropLast())
            }
        }
        
        return result
    }
    
    private func getPersonIdFromUserId(id: String) -> String {
        let utf8 = "ciscospark://us/PEOPLE/" + id
        let data = utf8.dataUsingEncoding(NSUTF8StringEncoding)
        var base64 = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        base64 = removePadding(base64)
        return base64
    }
}

private struct Client {
    let id = "C873b64d70536ed26df6d5f81e01dafccbd0a0af2e25323f7f69c7fe46a7be340"
    var secret: String!
    var base64Credentials: String!
    
    init() {
        secret = getSecret()
        base64Credentials = getBase64Credentials()
    }
    
    private func getBase64Credentials() -> String {
        let credentialData = "\(id):\(secret)".dataUsingEncoding(NSUTF8StringEncoding)!
        return credentialData.base64EncodedStringWithOptions([])
    }
    
    private func getSecret() -> String {
        let envDict = NSProcessInfo.processInfo().environment
        
        guard let secret = envDict["CLIENTSECRET"] else {
            print("Failed to get client secret from env")
            return ""
        }
        
        return secret
    }
}

private struct AccessToken {
    var value: String!
    
    private let accessTokenUrl = "https://idbroker.webex.com/idb/oauth2/v1/access_token"
    private let client = Client()
    
    init() {
        value = getBearerAccessToken()
    }
    
    private func getBearerAccessToken() -> String {
        let headers = ["Authorization": "Basic \(client.base64Credentials)"]
        
        let body = ["grant_type": "client_credentials",
                    "scope": "webexsquare:admin Identity:SCIM"]
        
        var adminToken = ""
        let semaphore = dispatch_semaphore_create(0)
        let queue = dispatch_queue_create("create-token-queue", nil)
        Alamofire.request(.POST, accessTokenUrl, parameters: body, headers: headers)
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        adminToken = json["access_token"].stringValue
                        dispatch_semaphore_signal(semaphore)
                    }
                case .Failure(let error):
                    print(error)
                    dispatch_semaphore_signal(semaphore)
                }
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return adminToken
    }
}