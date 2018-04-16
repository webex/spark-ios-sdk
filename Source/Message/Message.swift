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

public enum MessageEvent {
    case messageReceived(Message)
    case messageDeleted(String)
}

public class Message {

    /// The identifier of this message.
    public var id: String? {
        return self.activity.id
    }
    
    /// The roomId of the message
    public var roomId: String? {
        return self.activity.roomId
    }
    
    ///  The room type "group"/"direct"
    public var roomType: RoomType {
        return self.activity.roomType ?? RoomType.group
    }
    
    /// Id of who posted the message
    public var personId: String? {
        return self.activity.personId
    }
    
    /// Email of who posted the message
    public var personEmail: String? {
        return self.activity.personEmail
    }
    
    /// Created time of Message
    public var created: Date {
        return self.activity.created ?? Date()
    }
    
    public var mentions: [Mention]? {
        var mentions = [Mention]()
        if let peoples = self.activity.mentionedPeople {
            mentions.append(contentsOf: (peoples.map { Mention.person($0) }))
        }
        if let groups = self.activity.mentionedGroup {
            for group in groups where group == "all" {
                mentions.append(Mention.all)
                break
            }
        }
        return mentions.count > 0 ? mentions : nil
    }
    
    /// Content of Message
    public var text: String? {
        return self.activity.text
    }
    
    /// Attached Files of message
    public var files: [RemoteFile]? {
        return self.activity.files
    }
    
    private let activity: ActivityModel

    init(activity: ActivityModel) {
        self.activity = activity
    }
}

public enum Mention {
    case person(String)
    case all
}

public class LocalFile {
    
    let path: String
    let name: String
    let progressHandler: ((Double) -> Void)?
    
    public init(path: String, name: String? = nil, progressHandler: ((Double) -> Void)? = nil) {
        self.path = path
        self.name = name ?? URL(fileURLWithPath: path).lastPathComponent
        self.progressHandler = progressHandler
    }
}

public struct RemoteFile {
    public internal(set) var url: String?
    public internal(set) var displayName: String?
    public internal(set) var mimeType: String?
    public internal(set) var size: UInt64?
    public internal(set) var thumbnail: RemoteFileThumbnail?
    var secureContentRef: String?
    private init(){}
}

extension RemoteFile {
    
    init(local: LocalFile, downloadUrl: String, size: UInt64) {
        self.url = downloadUrl
        self.size = size
        self.displayName = local.name
        self.mimeType = local.name.mimeType
    }
    
    mutating func encrypt(key: String?, scr: SecureContentReference) {
        self.displayName = self.displayName?.encrypt(key: key)
        if let chilerScr = try? scr.encryptedSecureContentReference(withKey: key) {
            self.secureContentRef = chilerScr
        }
    }
    
    mutating func decrypt(key: String?) {
        self.displayName = self.displayName?.decrypt(key: key)
        self.secureContentRef = self.secureContentRef?.decrypt(key: key)
        if var thumbnail = self.thumbnail {
            thumbnail.secureContentRef = self.thumbnail?.secureContentRef?.decrypt(key: key)
            self.thumbnail = thumbnail
        }
    }
}

public struct RemoteFileThumbnail  {
    public var url: String?
    public var width: Int?
    public var height: Int?
    var secureContentRef: String?
    init(){}
}

extension RemoteFile : Mappable {

    /// File constructor.
    ///
    /// - note: for internal use only.
    public init?(map: Map) {
    }
    
    /// File mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        url <- map["url"]
        displayName <- map["displayName"]
        mimeType <- map["mimeType"]
        size <- map["fileSize"]
        thumbnail <- map["image"]
        secureContentRef <- map["scr"]
    }
}

extension RemoteFileThumbnail : Mappable {
    
    /// File thumbnail constructor.
    ///
    /// - note: for internal use only.
    public init?(map: Map) {}
    
    /// File thumbnail mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        url <- map["url"]
        width <- map["width"]
        height <- map["height"]
        secureContentRef <- map["scr"]
    }
}
