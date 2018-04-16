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
import UIKit
import Alamofire

/// *Spark* object is the entry point to use this Cisco Spark iOS SDK. A *Spark* object must be created with one of the following *Authenticator*.
///
/// - *OAuthAuthenticator* - this should be used when the SDK is to be authenticated as a registered user to Cisco Spark cloud.
///
/// ```` swift
///    let clientId = "Def123456..."
///    let clientSecret = "fed456..."
///    let scope = "spark:all"
///    let redirectUri = "MyCustomApplication://response"
///    let authenticator = OAuthAuthenticator(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
///    let spark = Spark(authenticator: authenticator)
///    ...
///    if !authenticator.authorized {
///      authenticator.authorize(parentViewController: self) { success in
///        if !success {
///            print("User not authorized")
///        }
///      }
///    }
/// ````
///
/// - *JWTAuthenticator* - this should be used when the SDK is to be authenticated as a guest user to Cisco Spark cloud.
///
/// ```` swift
///    let authenticator = JWTAuthenticator()
///    let spark = Spark(authenticator: authenticator)
///    ...
///    if !authenticator.authorized {
///      authenticator.authorizedWith(jwt: myJwt)
///    }
/// ````
///
/// - attention: All APIs on Cisco Spark iOS SDK are expected to run on the application's main thread, unless specified otherwise.
/// - since: 1.2.0
public class Spark {
    
    /// The version number of this Cisco Spark iOS SDK.
    ///
    /// - since: 1.2.0
    public static let version = "1.4.0"
    
    /// The logger for this SDK.
    ///
    /// - since: 1.2.0
    public var logger: Logger? {
        didSet {
            SDKLogger.shared.logger = self.logger
            verbose()
        }
    }
    
    /// Set the log level of the console logging.
    ///
    /// - since: 1.2.0
    public var consoleLogger: LogLevel {
        get {
            return SDKLogger.shared.console
        }
        set {
            SDKLogger.shared.console = newValue
        }
    }
    
    /// This is the *Authenticator* object from the application when constructing this Spark object.
    /// It can be used to check and modify authentication state.
    ///
    /// - since: 1.2.0
    public let authenticator: Authenticator
    
    /// *Phone* represents a calling device in Cisco Spark iOS SDK.
    /// It can be used to make audio and video calls on Cisco Spark.
    ///
    /// - since: 1.2.0
    public lazy var phone: Phone = Phone(authenticator: self.authenticator)
    
    /// MessageClient represent activities relates to the user.
    /// Use *activities* to create and manage the activities on behalf of the authenticated user.
    ///
    /// - since: 1.4.0
    public lazy var messages: MessageClient = MessageClient(phone: self.phone)
    
    /// Constructs a new *Spark* object with an *Authenticator*.
    ///
    /// - parameter authenticator: The authentication strategy for this SDK.
    /// - since: 1.2.0
    public init(authenticator: Authenticator) {
        self.authenticator = authenticator
        verbose()
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            var redirectedRequest = request
            if let originalRequest = task.originalRequest, let headers = originalRequest.allHTTPHeaderFields, let authorizationHeaderValue = headers["Authorization"] {
                var mutableRequest = request
                mutableRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
                redirectedRequest = mutableRequest
            }
            return redirectedRequest
        }
    }
    
    /// Rooms are virtual meeting places in Cisco Spark where people post messages and collaborate to get work done.
    /// Use *rooms* to manage the rooms on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Memberships API about how to manage people in a room.
    /// - see: Messages API about how post or otherwise manage the content in a room.
    public var rooms: RoomClient {
        return RoomClient(authenticator: authenticator)
    }
    
    /// People are registered users of Cisco Spark.
    /// Use *people*  to find a person on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Memberships API about how to manage people in a room.
    /// - see: Messages API about how post or otherwise manage the content in a room.
    public var people: PersonClient {
        return PersonClient(authenticator: authenticator)
    }
    
    /// Memberships represent a person's relationships to rooms.
    /// Use *membership* to manage the authenticated user's relationship to rooms.
    ///
    /// - since: 1.2.0
    /// - see: Rooms API about how to manage rooms.
    /// - see: Messages API about how post or otherwise manage the content in a room.
    public var memberships: MembershipClient {
        return MembershipClient(authenticator: authenticator)
    }

    
    /// Webhooks allow the application to be notified via HTTP (or HTTPS?) when a specific event occurs in Cisco Spark,
    /// e.g. a new message is posted into a specific room.
    /// Use *Webhooks* to create and manage the webhooks for specific events.
    ///
    /// - since: 1.2.0
    public var webhooks: WebhookClient {
        return WebhookClient(authenticator: authenticator)
    }
    
    /// Teams are groups of people with a set of rooms that are visible to all members of that team.
    /// Use *teams* to create and manage the teams on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Team Memberships API about how to manage people in a team.
    /// - see: Memberships API about how to manage people in a room.
    public var teams: TeamClient {
        return TeamClient(authenticator: authenticator)
    }
    
    /// Team Memberships represent a person's relationships to teams.
    /// Use *teamMemberships* to create and manage the team membership on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Teams API about how to manage teams.
    /// - see: Rooms API about how to manage rooms.
    public var teamMemberships: TeamMembershipClient {
        return TeamMembershipClient(authenticator: authenticator)
    }
    
    private func verbose() {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        let output = "Cisco_Spark_iOS_SDK/\(Spark.version)/WME-\(MediaEngineWrapper.sharedInstance.WMEVersion)/\(identifier)-\(UIDevice.current.systemVersion)"
        if let _ = SDKLogger.shared.logger {
            SDKLogger.shared.info(output)
        }
        else {
            print(output)
        }
    }
}

