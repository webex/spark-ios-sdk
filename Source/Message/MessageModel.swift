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

/// The struct of a MentionItemType on Cisco Spark.
///
/// - since: 1.4.0
public enum MessageAction : String{
    case post = "post"
    case share = "share"
    case delete = "delete"
    case tombstone = "tombstone"
}

/// The struct of a MentionItemType on Cisco Spark.
///
/// - since: 1.4.0
public enum MentionItemType : String{
    case person = "person"
    case group = "groupMention"
}
public enum GroupMentionType: String{
    case all = "all"
}

/// The struct of a FileType of file  on Cisco Spark.
///
/// - since: 1.4.0
public enum FileType : String{
    case Audio = "audio/"
    case Image = "image/"
    case PDF = "application/pdf"
    case Text = "text/plain"
    case PPT = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case Excel = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case Video = "video/"
    case Word = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case Zip = "application/x-zip-compressed"
    case Default = "application/octet-stream"
    case Unkown = "Unkown"
}

/// The struct of a Message on Cisco Spark.
///
/// - since: 1.4.0
public class MessageModel : Mappable {
    
    /// The identifier of this message.
    public var id: String?
    
    /// The roomId of the message, should only use for receive typing/untyping message
    public var roomId: String?
    
    ///  The room type "group"/"direct"
    public var roomType: RoomType?
    
    /// To target's personId & personEmail of message on "direct" room
    public var toPersonId: String?
    public var toPersonEmail: String?
    
    /// Content of Message
    public var text: String?
    
    /// MarkDown Content of Message
    //    public var html: String?
    
    /// Id & Email of who posted the message
    public var personId: String?
    public var personEmail: String?
    
    /// CreatedTime of Message
    public var created: Date?
    
    /// MentionedPeople & MentionedGroup
    public var mentionedPeople: [String]?
    public var mentionedGroup: [String]?
    
    /// Attached Files of message
    public var files : Array<FileObjectModel>?
    
    /// The encryptionKeyUrl of the message
    public var encryptionKeyUrl: String?
    
    /* The action of the message:
     post : send a text message to room
     share : share a content with participant in a room
     delete : delete an message item (the target of this message)
     */
    public var messageAction: MessageAction?
    
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
        created <- (map["published"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
        encryptionKeyUrl <- map["encryptionKeyUrl"]
        if let idStr = self.id{
            self.id = String.sparkEncodedUserId(idStr)
        }
        
        if let verb = map.JSON["verb"]{
            self.messageAction = MessageAction(rawValue: verb as! String)
        }
        
        if let actorDict = map.JSON["actor"] as? [String: Any]{
            if let personIdData = actorDict["entryUUID"]{
                self.personId = String.sparkEncodedUserId(personIdData as? String)
            }
            if let emailAddress = actorDict["emailAddress"]{
                self.personEmail = emailAddress as? String
            }
        }
        
        if let targetDict = map.JSON["target"] as? [String: Any]{
            if let roomIdData = targetDict["id"]{
                self.roomId = String.sparkEncodedRoomId(roomIdData as? String)
            }
            if let tags = targetDict["tags"] as? [String]{
                if tags.contains("ONE_ON_ONE"){
                    self.roomType = RoomType.direct
                }else{
                    self.roomType = RoomType.group
                }
            }else{
                self.roomType = RoomType.group
            }
        }
        
        if let objectDict = map.JSON["object"] as? [String: Any]{
            if let displayName = objectDict["displayName"]{
                self.text = displayName as? String
                //                self.html = displayName as? String
            }
            if let content = objectDict["content"]{
                self.text = content as? String
            }
            if let gMentions = objectDict["groupMentions"] as? [String: Any]{
                if let gMentionArr = gMentions["items"] as? [[String: Any]]{
                    self.mentionedGroup = [String]()
                    for mention in gMentionArr{
                        self.mentionedGroup?.append(mention["groupType"] as! String)
                    }
                }
            }
            if let mentions = objectDict["mentions"] as? [String: Any]{
                if let mentionArr = mentions["items"] as? [[String: Any]]{
                    self.mentionedPeople = [String]()
                    for mention in mentionArr{
                        let mentionId = mention["id"] as? String
                        self.mentionedPeople?.append(String.sparkEncodedUserId(mentionId)!)
                    }
                }
            }
            if let fileDict = objectDict["files"] as? [String: Any]{
                if let items = fileDict["items"] as? [[String: Any]]{
                    self.files = Array<FileObjectModel>()
                    for item in items{
                        let file = Mapper<FileObjectModel>().map(JSON: item)
                        self.files?.append(file!)
                    }
                }
            }
            
        }
        
    }
    
}
extension MessageModel{
    fileprivate var toPersonIdStr: String?{
        get{
            return self.toPersonId
        }
        set{
            self.toPersonId = String.sparkEncodedUserId(newValue)
        }
    }
    public func dictPresent()->[String: Any?]{
        return [
            "id": self.id,
            "roomId": self.roomId,
            "roomType": self.roomType?.rawValue,
            "toPersonId": self.toPersonId,
            "toPersonEmail": self.toPersonEmail,
            "text": self.text,
            //            "html": self.html,
            "personId": self.personId,
            "personEmail": self.personEmail,
            "created": self.created?.longString,
            "mentionedPeople": self.mentionedPeople,
            "mentionedGroup": self.mentionedGroup,
            "files": self.files?.toJSON(),
        ]
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
    public var fileType: FileType?
    
    public init(name: String, localFileUrl: String ,thumbNail: ThumbNailImageModel? = nil){
        self.displayName = name
        self.localFileUrl = localFileUrl
        self.image = thumbNail
    }
    public required init?(map: Map) {}
    public func mapping(map: Map) {
        displayName <- map["displayName"]
        objectType <- map["objectType"]
        fileSize <- map["fileSize"]
        scr <- map["scr"]
        url <- map["url"]
        image <- map["image"]
        mimeType <- map["mimeType"]
        
        if let mimeType = mimeType{
            if mimeType.contains("image/"){
                fileType = FileType.Image
            }else if mimeType.contains("video/"){
                fileType = FileType.Video
            }else if mimeType.contains("audio/"){
                fileType = FileType.Audio
            }else{
                fileType = FileType(rawValue:mimeType)
            }
        }
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

// MARK: MessageMentionModel
public class MessageMentionModel : Mappable{
    public var personId: String?
    public var objectType: String?
    public var groupType: GroupMentionType?
    public var mentionType: MentionItemType
    
    private init(personId: String?,type: MentionItemType){
        self.mentionType = type
        if self.mentionType == .person{
            if let personid = personId?.sparkSplitString(){
                self.personId = personid
            }else{
                self.personId = personId
            }
            self.objectType = "person"
        }else{
            self.objectType = "groupMention"
            self.groupType = .all
        }
    }
    
    public static func createPeopleMentionItem(personId: String?)->MessageMentionModel{
        return MessageMentionModel(personId: personId, type: MentionItemType.person)
    }
    public static func createGroupMentionItem()->MessageMentionModel{
        return MessageMentionModel(personId: nil, type: MentionItemType.group)
    }
    
    
    public required init?(map: Map){
        self.personId = map.JSON["id"] as? String
        self.mentionType = MentionItemType(rawValue:(map.JSON["objectType"] as! String))!
    }
    public func mapping(map: Map) {
        personId <- map["id"]
        objectType <- map["objectType"]
        groupType <- map["groupType"]
    }
}
extension Array {
    mutating func removeObject(equality: (Element) -> Bool) -> Element? {
        for (idx, element) in self.enumerated() {
            if equality(element) {
                return self.remove(at: idx);
            }
        }
        return nil
    }
}
extension String{
    public func sparkSplitString()->String{
        if let idDecode = self.base64Decoded(){
            if let idStr = idDecode.components(separatedBy: "/").last{
                if let firstid = String(idStr)?.components(separatedBy: ":").first{
                    return String(firstid)
                }else{
                    return String(idStr)
                }
            }else{
                return self
            }
        }else{
            return self
        }
    }
    public static func sparkEncodedUserId(_ userId: String?)->String?{
        if let userIdStr = userId{
            return "ciscospark://us/PEOPLE/\(userIdStr)".base64Encoded()
        }else{
            return nil
        }
    }
    public static func sparkEncodedRoomId(_ roomId: String?)->String?{
        if let roomIdStr = roomId{
            return "ciscospark://us/ROOM/\(roomIdStr)".base64Encoded()
        }else{
            return nil
        }
    }
    public static func sparkEncodedMessageId(_ messageId: String?)->String?{
        if let messageIdStr = messageId{
            return "ciscospark://us/MESSAGE/\(messageIdStr)".base64Encoded()
        }else{
            return nil
        }
    }
}

