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

import UIKit
import ObjectMapper

/// The struct of a Message on Cisco Spark.
///
/// - since: 1.4.0
public struct Activity {
    /// The identifier of this activity.
    public var id: String?
    
    /// The objectType of the Activity. Default is "activity"
    public var objectType: String?
    
    /// The url of the Activity. Default is "activity"
    public var url: String?
    
    /// The the time activity published "YYYY-MM-DDTHH:MM:SS.SSSZ".
    public var published: Date?
    
    /* The action verb the Activiy do
        add : adding participant to conversation
        leave : leave a conversation
        post : send a text message to conversation
        acknowledge: acknowledge an activity
        update: update a conversation title
        hide : hide a conversation
        unhide : unhide a conversation
        mute : mute a conversation
        unmute : unmute a conversation
        favorite : favorite a conversation
        unfavorite : unfavorite a conversation
        share : share a content with participant in a conversation
        delete : delete an activity item (the target of this activity)
    */
    public var verb: String?
    
    /// The actor of the Acitivity
    public var actor: ActivityActorModel?
    
    /// The activity object bring message/file info.
    public var object: ActivityObjectModel?
    
    /// The target of the activity
    public var target: ActivityTargetModel?
    
    /// The clientTempId of the activity
    public var clientTempId: String?
    
    /// The encryptionKeyUrl of the activity
    public var encryptionKeyUrl: String?
    
    ///
    
}

extension Activity: Mappable {
    
    /// Activity constructor.
    ///
    /// - note: for internal use only.
    public init?(map: Map){}
    
    /// Message mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        objectType <- map["objectType"]
        url <- map["url"]
        published <- (map["published"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
        verb <- map["verb"]
        actor <- map["actor"]
        object <- map["object"]
        target <- map["target"]
        clientTempId <- map["clientTempId"]
        encryptionKeyUrl <- map["encryptionKeyUrl"]
    }
}

public struct ActivityActorModel {
    var id: String?
    var objectType: String?
    var displayName: String?
    var orgId: String?
    var emailAddress: String?
    var entryUUID: String?
    var actorType: String? // Default is "PERSON"
}

public struct ActivityObjectModel {
    var id: String?
    var objectType: String?
    var url: String?
    var displayName: String?
    var contentCategory: String?
    var content: String?
    var contentType: String?
}

public struct ActivityTargetModel {
    var id: String?
    var objectType: String? // Default is "conversation"
    var url: String?
    var clientTempId: String?
    var encryptionKeyUrl: String?
}

public struct ActivityFlagItem{
    var activityUrl: String?
    var state: String? // Default is "flagged/unflagged"
    var id: String?
    var url: String?
    var created: Date?
}

extension ActivityActorModel: Mappable {
    public init?(map: Map) {}
    public mutating func mapping(map: Map) {
        id <- map["id"]
        objectType <- map["objectType"]
        displayName <- map["displayName"]
        orgId <- map["orgId"]
        emailAddress <- map["emailAddress"]
        entryUUID <- map["entryUUID"]
        actorType <- map["type"]
    }
}

extension ActivityObjectModel: Mappable {
    public init?(map: Map) {}
    public mutating func mapping(map: Map) {
        id <- map["id"]
        objectType <- map["objectType"]
        url <- map["url"]
        displayName <- map["displayName"]
        contentCategory <- map["contentCategory"]
        content <- map["content"]
        contentType <- map["contentType"]
    }
}

extension ActivityTargetModel: Mappable {
    public init?(map: Map){ }
    public mutating func mapping(map: Map) {
        id <- map["id"]
        objectType <- map["objectType"]
        url <- map["url"]
        clientTempId <- map["clientTempId"]
        encryptionKeyUrl <- map["encryptionKeyUrl"]
    }
}

extension ActivityFlagItem: Mappable {
    public init?(map: Map){ }
    public mutating func mapping(map: Map) {
        activityUrl <- map["flag-item"]
        state <- map["state"]
        id <- map["id"]
        url <- map["url"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}







