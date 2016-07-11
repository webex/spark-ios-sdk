// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

extension MessageClient {
    
    /// Lists all messages in a room. If present, includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter roomId: List messages for a room by id.
    /// - parameter before: List messages sent before a date and time, in ISO8601 format.
    /// - parameter beforeMessage: List messages sent before a message by id.
    /// - parameter max: Limit the maximum number of messages in the response.
    /// - returns: Messages array
    public func list(roomId roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil) throws -> [Message] {
        return try SyncUtil.getArray(roomId, before, beforeMessage, max, async: list)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a room.
    ///
    /// - parameter roomId: The room id.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - returns: Message
    public func postToRoom(roomId roomId: String, text: String? = nil, files: String? = nil) throws -> Message {
        return try SyncUtil.getObject(roomId, text, files, async: postToRoom)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a person.
    ///
    /// - parameter personId: The id of the recipient when sending a private 1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - returns: Message
    public func postToPerson(personId personId: String, text: String? = nil, files: String? = nil) throws -> Message {
        return try SyncUtil.getObject(personId, text, files, async: postToPerson)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a person.
    ///
    /// - parameter personEmail: The email address of the recipient when sendinga private 1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - returns: Message
    public func postToPerson(personEmail personEmail: EmailAddress, text: String? = nil, files: String? = nil) throws -> Message {
        return try SyncUtil.getObject(personEmail, text, files, async: postToPerson)
    }
    
    /// Shows details for a message by message id.
    ///
    /// - parameter messageId: The message id.
    /// - returns: Message
    public func get(messageId messageId: String) throws -> Message {
        return try SyncUtil.getObject(messageId, async: get)
    }
    
    /// Deletes a message by message id.
    ///
    /// - parameter messageId: The message id.
    /// - returns: Void
    public func delete(messageId messageId: String) throws {
        try SyncUtil.deleteObject(messageId, async: delete)
    }
}
