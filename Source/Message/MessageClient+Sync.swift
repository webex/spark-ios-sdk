//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension MessageClient {
    
    /// Lists all messages in a room. If present, includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    /// - Parameter roomId: List messages for a room by id.
    /// - Parameter before: List messages sent before a date and time, in ISO8601 format.
    /// - Parameter beforeMessage: List messages sent before a message by id.
    /// - Parameter max: Limit the maximum number of messages in the response.
    /// - Returns: Message array
    public func list(roomId roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil) throws -> [Message] {
        return try SyncUtil.getArray(roomId, before, beforeMessage, max, async: list)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a room.
    /// - Parameter roomId: The room id.
    /// - Parameter text: The plain text message to post to the room.
    /// - Parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - Parameter toPersonId: The id of the recipient when sending a private1:1 message.
    /// - Parameter toPersonEmail: The email address of the recipient when sendinga private 1:1 message.
    /// - Returns: Message
    public func create(roomId roomId: String? = nil, text: String? = nil, files: String? = nil, toPersonId: String? = nil, toPersonEmail: String? = nil) throws -> Message {
        return try SyncUtil.getObject(roomId, text, files, toPersonId, toPersonEmail, async: create)
    }
    
    /// Shows details for a message by message id.
    /// - Parameter messageId: The message id.
    /// - Returns: Message
    public func get(messageId messageId: String) throws -> Message {
        return try SyncUtil.getObject(messageId, async: get)
    }
    
    /// Deletes a message by message id.
    /// - Parameter messageId: The message id.
    /// - Returns: Void
    public func delete(messageId messageId: String) throws {
        try SyncUtil.deleteObject(messageId, async: delete)
    }
}
