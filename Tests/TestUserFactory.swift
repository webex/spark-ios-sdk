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
        let userName = NSUUID().uuidString
        let email = userName + "@squared.example.com"
        let headers = ["Authorization": "Bearer \(token.value)",
                       "Content-Type": "application/json"]
        
        let body: [String: Any] = ["clientId": client.id,
                                   "clientSecret": client.secret!,
                                   "emailTemplate": email,
                                   "displayName": userName,
                                   "password": "P@ssw0rd123",
                                   "entitlements": entitlements,
                                   "authCodeOnly": "false",
                                   "scopes": scopes]
        var user = TestUser()
        let semaphore = DispatchSemaphore(value: 0)
		let queue = DispatchQueue(label: "create-user-queue")
		Alamofire.request(testUserUrl, method: .post, parameters: body, encoding: .json, headers: headers).responseJSON(queue: queue) { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        user.token = json["token"]["access_token"].stringValue
                        user.id = json["user"]["id"].stringValue
                        user.email = EmailAddress.fromString(json["user"]["email"].stringValue)
                        user.name = json["user"]["name"].stringValue
                        user.orgId = json["user"]["orgId"].stringValue
						user.personId = self.getPersonIdFromUserId(id: user.id!)
                        
                        semaphore.signal()
                    }
                case .failure(let error):
                    print(error)
					semaphore.signal()
                }
        }
		_ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
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
        let data = utf8.data(using: String.Encoding.utf8)
        var base64 = data!.base64EncodedString(options: [])
        
        base64 = removePadding(base64: base64)
        return base64
    }
}

private struct Client {
    let id = "Cc5ce08d6eb24526c2af47c8ad39e58db1e07d3c53cbd4c9d359a5c471344c2fb"
    var secret: String!
    var base64Credentials: String!
    
    init() {
        secret = getSecret()
        base64Credentials = getBase64Credentials()
    }
    
    private func getBase64Credentials() -> String {
		let credentialData = "\(id):\(secret)".data(using: String.Encoding.utf8)!
        return credentialData.base64EncodedString(options: [])
    }
    
    private func getSecret() -> String {
        let envDict = ProcessInfo().environment        
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
        let semaphore = DispatchSemaphore(value: 0)
		let queue = DispatchQueue(label: "create-token-queue")

		
		Alamofire.request(accessTokenUrl, method: .post, parameters: body, headers: headers).responseJSON(queue: queue) { response in
			switch response.result {
			case .success:
				if let value = response.result.value {
					let json = JSON(value)
					adminToken = json["access_token"].stringValue
					semaphore.signal()
				}
			case .failure(let error):
				print(error)
				semaphore.signal()
			}
		}
		_ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return adminToken
    }
}
