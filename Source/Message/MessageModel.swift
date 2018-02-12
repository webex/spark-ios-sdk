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


/// The struct of a MessageType on Cisco Spark.
///
/// - since: 1.4.0
public enum MessageType : String{
    case TextMessage
    case FlagMessage
    case TypingMessage
}

/// The struct of a Message on Cisco Spark.
///
/// - since: 1.4.0
public class MessageModel : Mappable {
    
    /// The identifier of this message.
    public var id: String?
    
    /// The eventType of the message
    var eventType: String?
    {
        didSet {
            if(eventType == "conversation.activity"){
                self.messageType = MessageType.TextMessage
            }else if(eventType == "status.start_typing" || eventType == "status.stop_typing"){
                self.messageType = MessageType.TypingMessage
            }else if(eventType == "user.app_item"){
                self.messageType = MessageType.FlagMessage
            }
        }
    }
    
    /// The messageType of the message
    public var messageType: MessageType?
    
    /// The objectType of the Message. Default is "message"
    public var objectType: String?
    
    /// The url of the Message.
    public var url: String?
    
    
    /// The the time message published "YYYY-MM-DDTHH:MM:SS.SSSZ".
    public var published: Date?
    
    /* The action verb the Activiy do
     add : adding participant to room
     leave : leave a room
     post : send a text message to room
     acknowledge: acknowledge an message
     update: update a room title
     hide : hide a room
     unhide : unhide a room
     mute : mute a room
     unmute : unmute a room
     favorite : favorite a room
     unfavorite : unfavorite a room
     share : share a content with participant in a room
     delete : delete an message item (the target of this message)
     */
    public var verb: String?
    
    /// The actor of the Acitivity
    public var actor: MessageActorModel?
    
    /// The message object bring message/file info.
    public var object: MessageObjectModel?
    
    /// The target of the message
    public var target: MessageTargetModel?
    
    /// The clientTempId of the message
    public var clientTempId: String?
    
    /// The encryptionKeyUrl of the message
    public var encryptionKeyUrl: String?
    
    /// The timestamp of the message
    public var timestamp: String?
    
    /// The roomId of the message, should only use for receive typing/untyping message
    public var roomId: String?
    
    /// The message flag item action, should only use for receive flag/unflag message "create"/"delete"
    public var action: String?
    /// The message flag item info, should only use for receive flag/unflag message
    public var flagItem: MessageFlagItemModel?
    
    /// MessageModel constructor.
    ///
    /// - note: for internal use only.
    public init(){}
    
    /// Message constructor.
    ///
    /// - note: for internal use only.
    public required init?(map: Map){}
    
    /// Message mapping from JSON.
    ///
    /// - note: for internal use only.
    public func mapping(map: Map) {
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
        eventType <- map["eventType"]
        roomId <- map["conversationId"]
        flagItem <- map["appData"]
        action <- map["action"]
        timestamp<-map["timestamp"]
        if let idStr = self.id{
            let idString = "ciscospark://us/MESSAGE/\(idStr)"
            self.id = idString.base64Encoded()
        }
        if let roomId = self.roomId{
            let roomIdStr = "ciscospark://us/ROOM/\(roomId)"
            self.roomId = roomIdStr.base64Encoded()
        }
    }
}

// MARK: MessageActorModel
public class MessageActorModel : Mappable{
    public var id: String?
    public var displayName: String?
    public var orgId: String?
    public var emailAddress: String?
    public var actorType: String? // Default is "PERSON"
    
    public required init?(map: Map) {}
    public func mapping(map: Map) {
        id <- map["id"]
        displayName <- map["displayName"]
        orgId <- map["orgId"]
        emailAddress <- map["emailAddress"]
        actorType <- map["type"]
    }
}

// MARK: MessageObjectModel
public class MessageObjectModel : Mappable{
    public var id: String?
    public var objectType: String?
    public var url: String?
    public var displayName: String?
    public var contentCategory: String?
    public var content: String?
    public var contentType: String?
    public var mentions: [String : [MessageMentionModel]]?
    private var groupMentions:[String: [MessageMentionModel]]?
    public var files: [String: [FileObjectModel]]?
    
    public init(){}
    public required init?(map: Map) {}
    public func mapping(map: Map) {
        id <- map["id"]
        objectType <- map["objectType"]
        url <- map["url"]
        displayName <- map["displayName"]
        contentCategory <- map["contentCategory"]
        content <- map["content"]
        contentType <- map["contentType"]
        mentions <- map["mentions"]
        groupMentions <- map["groupMentions"]
        files <- map["files"]
        if let gMentions = groupMentions{
            if let mentions = mentions{
                let gMentionArr = gMentions["items"]!
                var mentionArr = mentions["items"]!
                mentionArr.append(contentsOf: gMentionArr)
                self.mentions = ["items": mentionArr]
            }else{
                self.mentions = gMentions
            }
        }
    }
}

// MARK: FileObjectModel
public class FileObjectModel : Mappable{
    public var displayName: String?
    public var mimeType: String?
    public var objectType: String?
    public var image: ThumbNailImageModel?
    public var fileSize: UInt64?
    public var scr: String?
    public var url: String?
    public var localFileUrl: String?
    
    public init(name: String, localFileUrl: String ,thumbNail: ThumbNailImageModel? = nil){
        self.displayName = name
        self.localFileUrl = localFileUrl
        self.image = thumbNail
    }
    public required init?(map: Map) {}
    public func mapping(map: Map) {
        displayName <- map["displayName"]
        mimeType <- map["mimeType"]
        objectType <- map["objectType"]
        fileSize <- map["fileSize"]
        scr <- map["scr"]
        url <- map["url"]
        image <- map["image"]
    }
}

public class ThumbNailImageModel : Mappable {
    public var width: Int?
    public var height: Int?
    public var scr: String?
    public var url: String?
    public var localFileUrl: String?
    public init(localFileUrl: String ,width: Int? = nil, height : Int? = nil){
        self.localFileUrl = localFileUrl
        self.width = width
        self.height = height
    }
    public required init?(map: Map) {}
    public func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        scr <- map["scr"]
        url <- map["url"]
    }
}

// MARK: MessageTargetModel
public class MessageTargetModel : Mappable{
    public var id: String?
    public var objectType: String? // Default is "conversation"
    public var url: String?
    public var encryptionKeyUrl: String?
    public var tags: [String]?
    
    public init(){}
    public required init?(map: Map) {}
    public func mapping(map: Map) {
        id <- map["id"]
        objectType <- map["objectType"]
        url <- map["url"]
        encryptionKeyUrl <- map["encryptionKeyUrl"]
        tags <- map["tags"]
        if(self.objectType == "conversation"){
            let roomIdStr = "ciscospark://us/ROOM/\(self.id!)"
            self.id = roomIdStr.base64Encoded()
        }
    }
}

// MARK: MessageFlagItemModel
public class MessageFlagItemModel: Mappable{
    public var messageUrl: String?
    public var state: String? // Default is "flagged/unflagged"
    public var id: String?
    public var url: String?
    public var created: Date?
    
    public required init?(map: Map) {}
    public func mapping(map: Map) {
        messageUrl <- map["flag-item"]
        state <- map["state"]
        id <- map["id"]
        url <- map["url"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
    }
}

// MARK: MessageMentionModel
public class MessageMentionModel : Mappable{
    public var personId: String?
    public var objectType: String?
    public var groupType: String?
    public var range: CountableClosedRange<Int>
    public var mentionType: MentionItemType
    
    public init(range: CountableClosedRange<Int>, personId: String?, type: MentionItemType){
        if let personid = personId,
            let userId = personid.base64Decoded(),
            let result = userId.components(separatedBy: "/").last {
            self.personId = String(result)
        }else{
            self.personId = personId
        }
        self.range = range
        self.mentionType = type
        if (self.mentionType == .person){
            self.objectType = "person"
        }else if(self.mentionType == .group){
            self.objectType = "groupMention"
            self.groupType = "all"
        }
    }
    
    public required init?(map: Map){
        self.personId = map.JSON["id"] as? String
        self.mentionType = MentionItemType(rawValue:(map.JSON["objectType"] as! String))!
        self.range  = 0...0
    }
    public func mapping(map: Map) {
        personId <- map["id"]
        objectType <- map["objectType"]
        groupType <- map["groupType"]
    }
}

