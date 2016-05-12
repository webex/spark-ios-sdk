//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import UIKit

public class Spark {
    
    /// The version number of this SDK.
    public static let version = "0.9.110"
    
    /// Indicates whether the SDK has been authorized.
    public static func authorized() -> Bool {
        return AuthManager.sharedInstance.authorized()
    }
    
    /// Deauthorize the SDK. If phone is registered, deregister the phone first.
    public static func deauthorize() {
        AuthManager.sharedInstance.invalidateAccessToken()
    }
    
    /// Initialize the SDK using client id, client secret, scope and redirect URI.
    ///
    /// - parameter clientId: The client id issued when creating your app.
    /// - parameter clientSecret: The client secret issued when creating your app.
    /// - parameter scope: Scope defines the level of access that your app requires.
    /// - parameter redirectUri: Redirect URI, must match one of the URIs provided during app registration.
    /// - parameter controller: View controller being redirected from and back when during OAuth flow.
    /// - returns: Void
    public static func initWith(clientId clientId: String, clientSecret: String, scope: String, redirectUri: String, controller: UIViewController) {
        let authMgr = AuthManager.sharedInstance
        authMgr.setup(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
        authMgr.authorizeFromController(controller)
    }
    
    /// Initialize the SDK using access token directly.
    ///
    /// - parameter clientId: The access token.
    /// - returns: Void
    public static func initWith(accessToken accessToken: String) {
        let authMgr = AuthManager.sharedInstance
        authMgr.setup(token: accessToken)
    }

    /// Setup storage plugin to SDK. Different clients may have different storage requirements, for example, security requirements.
    ///
    /// - parameter storage: The storage plugin implemented by client.
    /// - returns: Void
    public static func setupStorage(storage: Storagable) {
        UserDefaults.sharedInstance = UserDefaults(storage)
    }
}

extension Spark {
    
    /// Rooms are virtual meeting places where people post messages and collaborate to get work done.
    /// This API is used to manage the rooms themselves. Rooms are create and deleted with this API.
    /// You can also update a room to change its title, for example.
    ///
    /// - note:
    ///     - To manage people in a room see the Memberships API.
    ///     - To post or otherwise manage room content see the Messages API.
    public static var rooms: RoomClient {
        return RoomClient()
    }
    
    /// People are registered users of the Spark application.
    /// Currently, people can only be searched with this API.
    /// Future releases of the API will allow for more complete user administration.
    ///
    /// - note: To learn more about managing people in a room see the Memberships API
    public static var people: PersonClient {
        return PersonClient()
    }
    
    /// Memberships represent a person's relationship to a room. 
    /// Use this API to list members of any room that you're in or create memberships to invite someone to a room.
    /// Memberships can also be updated to make someome a moderator or deleted to remove them from the room.
    /// Just like in the Spark app, you must be a member of the room in order to list its memberships or invite people.
    public static var memberships: MembershipClient {
        return MembershipClient()
    }
    
    /// Messages are how we communicate in a room.
    /// In Spark, each message is displayed on its own line along with a timestamp and sender information.
    /// Use this API to list, create, and delete messages. Each message can contain plain text and file attachments.
    /// Just like in the Spark app, you must be a member of the room in order to target it with this API.
    public static var messages: MessageClient {
        return MessageClient()
    }
    
    /// Webhooks allow your app to be notified via HTTP when a specific event occurs on Spark.
    /// For example, your app can register a webhook to be notified when a new message is posted into a specific room.
    /// Events trigger in near real-time allowing your app and backend IT systems to stay in sync with new content and room activity.
    /// This initial release is quite limited in that it only supports a single messages resource with a single created event. 
    /// However, this API was designed to be extensible and forms the foundation for supporting a wide array of platform events in future releases.
    public static var webhooks: WebhookClient {
        return WebhookClient()
    }

    /// Phone allows your app to make media calls on Spark.
    public static var phone: Phone {
        return Phone.sharedInstance
    }
}




