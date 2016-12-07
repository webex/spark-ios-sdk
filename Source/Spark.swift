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
public class Spark {
    
    /// The version number of this SDK.
    public static let version = "1.0.0"
    
    /// Toggle to enable or disable console log output.
    ///
    /// - parameter enable: Set True to enable console log, False as not.
    /// - returns: Void
    public static func toggleConsoleLogger(_ enable: Bool) {
        LoggerManager.sharedInstance.toggleConsoleLogger(enable)
    }
    
    /// AuthenticationStrategy allows your application to check and modify authentication state
    public let authenticationStrategy: AuthenticationStrategy
    
    /// Phone allows your application to make media calls on Spark.
    public let phone: Phone
    
    /// CallNotificationCenter allows your application to be notified of call events
    public let callNotificationCenter: CallNotificationCenter
    
    public init(authenticationStrategy: AuthenticationStrategy) {
        self.authenticationStrategy = authenticationStrategy
        let deviceService = DeviceService(authenticationStrategy: authenticationStrategy)
        let callManager = CallManager(authenticationStrategy: authenticationStrategy, deviceService: deviceService)
        let webSocketService = WebSocketService(authenticationStrategy: authenticationStrategy, callManager: callManager)
        let applicationLifecycleObserver = ApplicationLifecycleObserver(webSocketService: webSocketService, callManager: callManager, deviceService: deviceService)
        phone = Phone(authenticationStrategy: authenticationStrategy, applicationLifecycleObserver: applicationLifecycleObserver, webSocketService: webSocketService, callManager: callManager, deviceService: deviceService)
        callNotificationCenter = callManager.callNotificationCenter
    }
    
    /// Rooms are virtual meeting places where people post messages and collaborate to get work done.
    /// This API is used to manage the rooms themselves. Rooms are create and deleted with this API.
    /// You can also update a room to change its title, for example.
    ///
    /// - note:
    ///     - To manage people in a room see the Memberships API.
    ///     - To post or otherwise manage room content see the Messages API.
    public var rooms: RoomClient {
        return RoomClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// People are registered users of the Spark application.
    /// Currently, people can only be searched with this API.
    /// Future releases of the API will allow for more complete user administration.
    ///
    /// - note: To learn more about managing people in a room see the Memberships API
    public var people: PersonClient {
        return PersonClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Memberships represent a person's relationship to a room.
    /// Use this API to list members of any room that you're in or create memberships to invite someone to a room.
    /// Memberships can also be updated to make someome a moderator or deleted to remove them from the room.
    /// Just like in the Spark app, you must be a member of the room in order to list its memberships or invite people.
    public var memberships: MembershipClient {
        return MembershipClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Messages are how we communicate in a room.
    /// In Spark, each message is displayed on its own line along with a timestamp and sender information.
    /// Use this API to list, create, and delete messages. Each message can contain plain text and file attachments.
    /// Just like in the Spark app, you must be a member of the room in order to target it with this API.
    public var messages: MessageClient {
        return MessageClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Webhooks allow your app to be notified via HTTP when a specific event occurs on Spark.
    /// For example, your app can register a webhook to be notified when a new message is posted into a specific room.
    /// Events trigger in near real-time allowing your app and backend IT systems to stay in sync with new content and room activity.
    /// This initial release is quite limited in that it only supports a single messages resource with a single created event.
    /// However, this API was designed to be extensible and forms the foundation for supporting a wide array of platform events in future releases.
    public var webhooks: WebhookClient {
        return WebhookClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Teams are groups of people with a set of rooms that are visible to all members of that team.
    /// This API is used to manage the teams themselves.
    /// Teams are create and deleted with this API. You can also update a team to change its team, for example.
    ///
    /// - note:
    ///     - To manage people in a team see the Team Memberships API.
    ///     - To manage team rooms see the Rooms API.
    public var teams: TeamClient {
        return TeamClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Team Memberships represent a person's relationship to a team.
    /// Use this API to list members of any team that you're in or create memberships to invite someone to a team.
    /// Team memberships can also be updated to make someome a moderator or deleted to remove them from the team.
    /// Just like in the Spark app, you must be a member of the team in order to list its memberships or invite people.
    public var teamMemberships: TeamMembershipClient {
        return TeamMembershipClient(authenticationStrategy: authenticationStrategy)
    }
}

@available(*, deprecated)
extension Spark {
    
    /// Indicates whether the SDK has been authorized.
    @available(*, deprecated, message: "Use AuthenticationStrategy.authorized() instead")
    public static func authorized() -> Bool {
        return SparkInstance.sharedInstance.authenticationStrategy.authorized
    }
    
    /// Deauthorize the SDK. If the phone is registered it should be deregistered before calling this method.
    @available(*, deprecated, message: "Use AuthenticationStrategy.deauthorize() instead")
    public static func deauthorize() {
        SparkInstance.sharedInstance.authenticationStrategy.deauthorize()
        SparkInstance.sharedInstance.authenticationStrategy.setDelegateStrategy(nil)
        SparkInstance.clearGlobalAuthenticationStrategyInformation()
    }
    
    /// Retrieves the access token of the SparkSDK if the user is logged in to Spark.
    @available(*, deprecated, message: "Use AuthenticationStrategy.accessToken(completionHandler:) instead")
    public static func accessToken(completionHandler: @escaping (String?) -> Void) {
        return SparkInstance.sharedInstance.authenticationStrategy.accessToken(completionHandler: completionHandler)
    }
    
    /// Initialize the SDK using client id, client secret, scope and redirect URI.
    ///
    /// - parameter clientId: The client id issued when creating your app.
    /// - parameter clientSecret: The client secret issued when creating your app.
    /// - parameter scope: Scope defines the level of access that your app requires.
    /// - parameter redirectUri: Redirect URI, must match one of the URIs provided during app registration.
    /// - parameter controller: View controller being redirected from and back when during OAuth flow.
    /// - returns: Void
    @available(*, deprecated, message: "Use Spark(authenticationStrategy:) with an OAuthStrategy instead and then call OAuthStrategy.authorize(parentViewController:completionHandler:)")
    public static func initWith(clientId: String, clientSecret: String, scope: String, redirectUri: String, controller: UIViewController) {
        let oauthStrategy = OAuthStrategy(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
        SparkInstance.sharedInstance.authenticationStrategy.setDelegateStrategy(oauthStrategy)
        SparkInstance.saveGlobalOAuth(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
        
        oauthStrategy.authorize(parentViewController: controller, completionHandler: nil)
    }
    
    /// Initialize the SDK using access token directly.
    ///
    /// - parameter clientId: The access token.
    /// - returns: Void
    @available(*, deprecated, message: "Use Spark(authenticationStrategy:) with a new AuthenticationStrategy of your own devising")
    public static func initWith(accessToken: String) {
        let simpleAuthStrategy = SimpleAuthStrategy(accessToken: accessToken)
        SparkInstance.sharedInstance.authenticationStrategy.setDelegateStrategy(simpleAuthStrategy)
        SparkInstance.saveGlobalSimpleAccessToken(accessToken)
    }
    
    /// Rooms are virtual meeting places where people post messages and collaborate to get work done.
    /// This API is used to manage the rooms themselves. Rooms are create and deleted with this API.
    /// You can also update a room to change its title, for example.
    ///
    /// - note:
    ///     - To manage people in a room see the Memberships API.
    ///     - To post or otherwise manage room content see the Messages API.
    @available(*, deprecated, message: "Use the instance property Spark.rooms instead")
    public static var rooms: RoomClient {
        return RoomClient(authenticationStrategy: SparkInstance.sharedInstance.authenticationStrategy)
    }
    
    /// People are registered users of the Spark application.
    /// Currently, people can only be searched with this API.
    /// Future releases of the API will allow for more complete user administration.
    ///
    /// - note: To learn more about managing people in a room see the Memberships API
    @available(*, deprecated, message: "Use the instance property Spark.people instead")
    public static var people: PersonClient {
        return PersonClient(authenticationStrategy: SparkInstance.sharedInstance.authenticationStrategy)
    }
    
    /// Memberships represent a person's relationship to a room. 
    /// Use this API to list members of any room that you're in or create memberships to invite someone to a room.
    /// Memberships can also be updated to make someome a moderator or deleted to remove them from the room.
    /// Just like in the Spark app, you must be a member of the room in order to list its memberships or invite people.
    @available(*, deprecated, message: "Use the instance property Spark.memberships instead")
    public static var memberships: MembershipClient {
        return MembershipClient(authenticationStrategy: SparkInstance.sharedInstance.authenticationStrategy)
    }
    
    /// Messages are how we communicate in a room.
    /// In Spark, each message is displayed on its own line along with a timestamp and sender information.
    /// Use this API to list, create, and delete messages. Each message can contain plain text and file attachments.
    /// Just like in the Spark app, you must be a member of the room in order to target it with this API.
    @available(*, deprecated, message: "Use the instance property Spark.messages instead")
    public static var messages: MessageClient {
        return MessageClient(authenticationStrategy: SparkInstance.sharedInstance.authenticationStrategy)
    }
    
    /// Webhooks allow your app to be notified via HTTP when a specific event occurs on Spark.
    /// For example, your app can register a webhook to be notified when a new message is posted into a specific room.
    /// Events trigger in near real-time allowing your app and backend IT systems to stay in sync with new content and room activity.
    /// This initial release is quite limited in that it only supports a single messages resource with a single created event. 
    /// However, this API was designed to be extensible and forms the foundation for supporting a wide array of platform events in future releases.
    @available(*, deprecated, message: "Use the instance property Spark.webhooks instead")
    public static var webhooks: WebhookClient {
        return WebhookClient(authenticationStrategy: SparkInstance.sharedInstance.authenticationStrategy)
    }
    
    /// Teams are groups of people with a set of rooms that are visible to all members of that team. 
    /// This API is used to manage the teams themselves. 
    /// Teams are create and deleted with this API. You can also update a team to change its team, for example.
    ///
    /// - note:
    ///     - To manage people in a team see the Team Memberships API.
    ///     - To manage team rooms see the Rooms API.
    @available(*, deprecated, message: "Use the instance property Spark.teams instead")
    public static var teams: TeamClient {
        return TeamClient(authenticationStrategy: SparkInstance.sharedInstance.authenticationStrategy)
    }
    
    /// Team Memberships represent a person's relationship to a team. 
    /// Use this API to list members of any team that you're in or create memberships to invite someone to a team. 
    /// Team memberships can also be updated to make someome a moderator or deleted to remove them from the team.
    /// Just like in the Spark app, you must be a member of the team in order to list its memberships or invite people.
    @available(*, deprecated, message: "Use the instance property Spark.teamMemberships instead")
    public static var teamMemberships: TeamMembershipClient {
        return TeamMembershipClient(authenticationStrategy: SparkInstance.sharedInstance.authenticationStrategy)
    }

    /// Phone allows your app to make media calls on Spark.
    @available(*, deprecated, message: "Use the instance property Spark.phone instead")
    public static var phone: Phone {
        return SparkInstance.sharedInstance.phone
    }
}
