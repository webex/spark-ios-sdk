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
import UIKit


/// The main entry point into the SDK. Contains methods for initializing the SDK and verifying developer and end user credentials.
open class Spark {
    
    /// The version number of this SDK.
    open static let version = "1.0.0"
    
    /// Indicates whether the SDK has been authorized.
    open static func authorized() -> Bool {
        return AuthManager.sharedInstance.authorized()
    }
    
    /// Deauthorize the SDK. If phone is registered, deregister the phone first.
    open static func deauthorize() {
        AuthManager.sharedInstance.deauthorize()
    }
    
    /// Returns the access token of the SparkSDK if the user is logged in to Spark.
    public static func accessToken() -> String? {
        if let authorization = AuthManager.sharedInstance.getAuthorization(),
        let token = authorization["Authorization"],
        let spaceIndex = token.characters.index(of: " ") {
            return token.substring(from: token.characters.index(after: spaceIndex))
        }
        return nil
    }

    /// Initialize the SDK using client id, client secret, scope and redirect URI.
    ///
    /// - parameter clientId: The client id issued when creating your app.
    /// - parameter clientSecret: The client secret issued when creating your app.
    /// - parameter scope: Scope defines the level of access that your app requires.
    /// - parameter redirectUri: Redirect URI, must match one of the URIs provided during app registration.
    /// - parameter controller: View controller being redirected from and back when during OAuth flow.
    /// - returns: Void
    open static func initWith(clientId: String, clientSecret: String, scope: String, redirectUri: String, controller: UIViewController) {
        let clientAccount = ClientAccount(clientId: clientId, clientSecret: clientSecret)
        AuthManager.sharedInstance.authorize(clientAccount: clientAccount,
                                             scope: scope,
                                             redirectUri: redirectUri,
                                             controller: controller)
    }
    
    /// Initialize the SDK using access token directly.
    ///
    /// - parameter clientId: The access token.
    /// - returns: Void
    open static func initWith(accessToken: String) {
        AuthManager.sharedInstance.authorize(token: accessToken)
    }
    
    /// Toggle to enable or disable console log output.
    ///
    /// - parameter enable: Set True to enable console log, False as not.
    /// - returns: Void
    open static func toggleConsoleLogger(_ enable: Bool) {
        LoggerManager.sharedInstance.toggleConsoleLogger(enable)
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
    
    /// Teams are groups of people with a set of rooms that are visible to all members of that team. 
    /// This API is used to manage the teams themselves. 
    /// Teams are create and deleted with this API. You can also update a team to change its team, for example.
    ///
    /// - note:
    ///     - To manage people in a team see the Team Memberships API.
    ///     - To manage team rooms see the Rooms API.
    public static var teams: TeamClient {
        return TeamClient()
    }
    
    /// Team Memberships represent a person's relationship to a team. 
    /// Use this API to list members of any team that you're in or create memberships to invite someone to a team. 
    /// Team memberships can also be updated to make someome a moderator or deleted to remove them from the team.
    /// Just like in the Spark app, you must be a member of the team in order to list its memberships or invite people.
    public static var teamMemberships: TeamMembershipClient {
        return TeamMembershipClient()
    }

    /// Phone allows your app to make media calls on Spark.
    public static var phone: Phone {
        return Phone.sharedInstance
    }
}




