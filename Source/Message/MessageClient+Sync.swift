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

extension MessageClient {
    
    /// Lists all messages in a room. If present, includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter roomId: List messages for a room by id.
    /// - parameter before: List messages sent before a date and time, in ISO8601 format.
    /// - parameter beforeMessage: List messages sent before a message by id.
    /// - parameter max: Limit the maximum number of messages in the response.
    /// - returns: Messages array
    public func list(roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil) throws -> [Message] {
        return try SyncUtil.getArray(roomId, before, beforeMessage, max, async: list)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a room.
    ///
    /// - parameter roomId: The room id.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - returns: Message
    public func postToRoom(roomId: String, text: String? = nil, files: String? = nil) throws -> Message {
        return try SyncUtil.getObject(roomId, text, files, async: postToRoom)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a person.
    ///
    /// - parameter personId: The id of the recipient when sending a private 1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - returns: Message
    public func postToPerson(personId: String, text: String? = nil, files: String? = nil) throws -> Message {
        return try SyncUtil.getObject(personId, text, files, async: postToPerson)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a person.
    ///
    /// - parameter personEmail: The email address of the recipient when sendinga private 1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - returns: Message
    public func postToPerson(personEmail: EmailAddress, text: String? = nil, files: String? = nil) throws -> Message {
        return try SyncUtil.getObject(personEmail, text, files, async: postToPerson)
    }
    
    /// Shows details for a message by message id.
    ///
    /// - parameter messageId: The message id.
    /// - returns: Message
    public func get(messageId: String) throws -> Message {
        return try SyncUtil.getObject(messageId, async: get)
    }
    
    /// Deletes a message by message id.
    ///
    /// - parameter messageId: The message id.
    /// - returns: Void
    public func delete(messageId: String) throws {
        try SyncUtil.deleteObject(messageId, async: delete)
    }
}
