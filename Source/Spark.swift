//
//  Spark.swift
//  SparkSDK
//
//  Created by bxu3 on 2/24/16.
//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import UIKit


public class Spark {
    
    // TODO: check if it's ok to get sdk version
    public static let version = "1.0.0"
    
    public static func authorized() -> Bool {
        return AuthManager.sharedInstance.authorized()
    }
    
    public static var accessToken: String? {
        return AuthManager.sharedInstance.accessToken?.accessTokenString
    }
    
    public static func deauthorize() {
        AuthManager.sharedInstance.invalidateAccessToken()
    }
    
    public static func initWith(clientId clientId: String, clientSecret: String, scope: String, redirectUri: String) {
        let authMgr = AuthManager.sharedInstance
        authMgr.setup(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
    }
    
    public static func initWith(accessToken accessToken: String) {
        let authMgr = AuthManager.sharedInstance
        authMgr.setup(token: accessToken)
    }
    
    public static func authorizeFromController(controller: UIViewController) {
        AuthManager.sharedInstance.authorizeFromController(controller)
    }

    public static func setupStorage(storage: Storagable) {
        UserDefaults.sharedInstance = UserDefaults(storage)
    }
}

extension Spark {
    public static var rooms: RoomClient {
        return RoomClient()
    }
    
    public static var people: PersonClient {
        return PersonClient()
    }
    
    public static var memberships: MembershipClient {
        return MembershipClient()
    }
    
    public static var messages: MessageClient {
        return MessageClient()
    }
    
    public static var webhooks: WebhookClient {
        return WebhookClient()
    }

    public static var phone: Phone {
        return Phone.sharedInstance
    }
}




