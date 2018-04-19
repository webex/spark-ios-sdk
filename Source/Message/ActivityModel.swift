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
import ObjectMapper

struct ActivityModel {
    
    enum Kind : String {
        case post
        case share
        case delete
        case tombstone
        case acknowledge
    }
    
    private(set) var id: String?
    private(set) var roomId: String?
    private(set) var roomType: RoomType?
    private(set) var toPersonId: String?
    private(set) var toPersonEmail: String?
    private(set) var text: String?
    private(set) var personId: String?
    private(set) var personEmail: String?
    private(set) var created: Date?
    private(set) var mentionedPeople: [String]?
    private(set) var mentionedGroup: [String]?
    private(set) var files : [RemoteFile]?
    private(set) var encryptionKeyUrl: String?
    private(set) var kind: ActivityModel.Kind?
}

extension ActivityModel : ImmutableMappable {
    
    /// ActivityModel constructor.
    ///
    /// - note: for internal use only.
    public init(map: Map) throws {
        self.id = try? map.value("id", using: IdentityTransform(for: IdentityType.message))
        self.created = try? map.value("published", using: CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
        self.encryptionKeyUrl = try? map.value("encryptionKeyUrl")
        self.kind = try? map.value("verb", using: VerbTransform())
        self.personId = try? map.value("actor.entryUUID", using: IdentityTransform(for: IdentityType.people))
        self.personEmail = try? map.value("actor.emailAddress")
        self.roomId = try? map.value("target.id", using: IdentityTransform(for: IdentityType.room))
        self.roomType = try? map.value("target.tags", using: RoomTypeTransform())
        if let text: String = try? map.value("object.displayName") {
            self.text = text
        }
        if let text: String = try? map.value("object.content") {
            self.text = text
        }
        if let groupItems: [[String: Any]] = try? map.value("object.groupMentions.items"), groupItems.count > 0 {
            self.mentionedGroup = groupItems.compactMap { value in
                return value["groupType"] as? String
            }
        }
        if let peopleItems: [[String: Any]] = try? map.value("object.mentions.items"), peopleItems.count > 0 {
            self.mentionedPeople = peopleItems.compactMap { value in
                return (value["id"] as? String)?.hydraFormat(for: .people)
            }
        }
        if let fileItems: [[String: Any]] = try? map.value("object.files.items"), fileItems.count > 0 {
            self.files = fileItems.compactMap { value in
                return Mapper<RemoteFile>().map(JSON: value)
            }
        }
    }
    /// Mapping activity model to json format.
    ///
    /// - since: 1.4.0
    public func mapping(map: Map) {
        self.id >>> map["id"]
        self.roomId >>> map["roomId"]
        self.kind >>> (map["verb"], VerbTransform())
        self.roomType >>> (map["roomType"], RoomTypeTransform())
        self.toPersonId >>> map["toPersonId"]
        self.toPersonEmail >>> map["toPersonEmail"]
        self.text >>> map["text"]
        self.personId >>> map["personId"]
        self.personEmail >>> map["personEmail"]
        self.created?.longString >>> map["created"]
        self.mentionedPeople >>> map["mentionedPeople"]
        self.mentionedGroup >>> map["mentionedGroup"]
        self.files >>> map["files"]
    }
}

extension ActivityModel {
    func decrypt(key: String?) -> ActivityModel {
        var activity = self
        activity.text = activity.text?.decrypt(key: key)
        activity.files = activity.files?.map { f in
            var file = f
            file.decrypt(key: key)
            return file
        }
        return activity;
    }
}

enum IdentityType : String {
    case room
    case people
    case message
}

extension String {
    
    var locusFormat: String {
        if let decode = self.base64Decoded(), let id = decode.components(separatedBy: "/").last {
            if let first = id.components(separatedBy: ":").first {
                return first
            } else {
                return id
            }
        }
        return self
    }
    
    func hydraFormat(for type: IdentityType) -> String {
        return "ciscospark://us/\(type.rawValue.uppercased())/\(self)".base64Encoded() ?? self
    }
    
    func encrypt(key: String?) -> String {
        if let key = key, let text = try? CjoseWrapper.ciphertext(fromContent: self.data(using: .utf8), key: key) {
            return text
        }
        return self
    }
    
    func decrypt(key: String?) -> String {
        if let key = key, let data = try? CjoseWrapper.content(fromCiphertext: self, key: key), let text = String(data: data, encoding: .utf8) {
            return text
        }
        return self
    }
}

private class IdentityTransform : TransformType {
    
    private var identityType: IdentityType
    
    init(for type: IdentityType) {
        self.identityType = type
    }
    
    func transformFromJSON(_ value: Any?) -> String? {
        return (value as? String)?.hydraFormat(for: self.identityType)
    }
    
    func transformToJSON(_ value: String?) -> String? {
        return value?.locusFormat
    }
}

private class VerbTransform : TransformType {
    
    func transformFromJSON(_ value: Any?) -> ActivityModel.Kind? {
        if let verb = value as? String {
            return ActivityModel.Kind(rawValue: verb)
        }
        return nil
    }
    
    func transformToJSON(_ value: ActivityModel.Kind?) -> String? {
        if let value = value {
            return value.rawValue
        }
        return nil
    }
}

private class RoomTypeTransform : TransformType {
    
    func transformFromJSON(_ value: Any?) -> RoomType? {
        if let tags = value as? String, tags.contains("ONE_ON_ONE") {
            return RoomType.direct
        }
        return RoomType.group
    }
    
    func transformToJSON(_ value: RoomType?) -> String? {
        if let value = value, value == RoomType.direct {
            return "ONE_ON_ONE"
        }
        return nil
    }
}
