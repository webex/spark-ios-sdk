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

/// The struct of a message event
///
/// - since: 1.2.0
public enum MessageEvent {
    case messageReceived(Message)
    case messageDeleted(String)
}

/// The struct of a Message on Cisco Spark.
///
/// - since: 1.2.0
public struct Message {

    /// The identifier of this message.
    public var id: String? {
        return self.activity.id
    }
    
     /// The identifier of the room where this message was posted.
    public var roomId: String? {
        return self.activity.roomId
    }
    
    ///  The room type "group"/"direct"
    public var roomType: RoomType {
        return self.activity.roomType ?? RoomType.group
    }
    
    /// The identifier of the person who sent this message.
    public var personId: String? {
        return self.activity.personId
    }
    
    /// The email address of the person who sent this message.
    public var personEmail: String? {
        return self.activity.personEmail
    }
    
    /// The identifier of the recipient when sending a private 1:1 message.
    public var toPersonId: String? {
        // TODO
        return nil
    }
    
    /// The email address of the recipient when sending a private 1:1 message.
    public var toPersonEmail: EmailAddress? {
        // TODO
        return nil
    }
    
    /// The timestamp that the message being created.
    public var created: Date? {
        return self.activity.created
    }
    
    /// The people mentioned in the message
    ///
    /// - since: 1.4.0
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
    
    /// The content of the message.
    public var text: String? {
        return self.activity.text
    }
    
    /// A array of the attachments in the message.
    ///
    /// - since: 1.4.0
    public var files: [RemoteFile]? {
        return self.activity.files
    }
    
    private let activity: ActivityModel

    init(activity: ActivityModel) {
        self.activity = activity
    }
}

extension Message : CustomStringConvertible {
    public var description: String {
        get {
            return activity.toJSONString(prettyPrint: true) ?? ""
        }
    }
}

public class LocalFile {
    
    public class Thumbnail {
        let path: String
        let width: Int
        let height: Int
        let size: UInt64
        
        public init?(path: String, width: Int, height: Int) {
            if width <= 0 || height <= 0 {
                return nil
            }
            self.path = path
            self.width = width
            self.height = height
            if !FileManager.default.fileExists(atPath: path) || !FileManager.default.isReadableFile(atPath: path) {
                return nil
            }
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: path), let size = attrs[FileAttributeKey.size] as? UInt64 else {
                return nil
            }
            self.size = size
        }
    }
    
    let path: String
    let name: String
    let size: UInt64
    let progressHandler: ((Double) -> Void)?
    let thumbnail: Thumbnail?
    
    public init?(path: String, name: String? = nil, thumbnail: Thumbnail? = nil, progressHandler: ((Double) -> Void)? = nil) {
        self.path = path
        self.name = name ?? URL(fileURLWithPath: path).lastPathComponent
        self.thumbnail = thumbnail
        self.progressHandler = progressHandler
        if !FileManager.default.fileExists(atPath: path) || !FileManager.default.isReadableFile(atPath: path) {
            return nil
        }
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path), let size = attrs[FileAttributeKey.size] as? UInt64 else {
            return nil
        }
        self.size = size
    }
}

public struct RemoteFile {
    
    public struct Thumbnail {
        public internal(set) var width: Int?
        public internal(set) var height: Int?
        var url: String?
        var secureContentRef: String?
    }
    
    public internal(set) var displayName: String?
    public internal(set) var mimeType: String?
    public internal(set) var size: UInt64?
    public internal(set) var thumbnail: Thumbnail?
    var url: String?
    var secureContentRef: String?
}

extension RemoteFile {
    
    init(local: LocalFile, downloadUrl: String) {
        self.url = downloadUrl
        self.displayName = local.name
        self.size = local.size
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
        self.thumbnail?.decrypt(key: key)
    }
}

extension RemoteFile.Thumbnail {
    
    init(local: LocalFile.Thumbnail, downloadUrl: String) {
        self.url = downloadUrl
        self.width = local.width
        self.height = local.height
    }
    
    mutating func encrypt(key: String?, scr: SecureContentReference) {
        if let chilerScr = try? scr.encryptedSecureContentReference(withKey: key) {
            self.secureContentRef = chilerScr
        }
    }
    
    fileprivate mutating func decrypt(key: String?) {
        self.secureContentRef = self.secureContentRef?.decrypt(key: key)
    }
    
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

extension RemoteFile.Thumbnail : Mappable {
    
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
