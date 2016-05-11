//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Message HTTP client.
public class MessageClient: CompletionHandlerType<Message> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("messages")
    }
    
    /// Lists all messages in a room. If present, includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    /// - Parameter roomId: List messages for a room by id.
    /// - Parameter before: List messages sent before a date and time, in ISO8601 format.
    /// - Parameter beforeMessage: List messages sent before a message by id.
    /// - Parameter max: Limit the maximum number of messages in the response.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func list(roomId roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let query = HttpParameters([
            "roomId": roomId,
            "before": before,
            "beforeMessage": beforeMessage,
            "max": max])
        
        let request = requestBuilder()
            .method(.GET)
            .query(query)
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a room.
    /// - Parameter roomId: The room id.
    /// - Parameter text: The plain text message to post to the room.
    /// - Parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - Parameter toPersonId: The id of the recipient when sending a private1:1 message.
    /// - Parameter toPersonEmail: The email address of the recipient when sendinga private 1:1 message.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func create(roomId roomId: String? = nil, text: String? = nil, files: String? = nil, toPersonId: String? = nil, toPersonEmail: String? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
            "roomId": roomId,
            "text": text,
            "files": files,
            "toPersonId": toPersonId,
            "toPersonEmail": toPersonEmail])
        
        let request = requestBuilder()
            .method(.POST)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Shows details for a message by message id.
    /// - Parameter messageId: The message id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func get(messageId messageId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a message by message id.
    /// - Parameter messageId: The message id.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: A closure to be executed once the request has finished.
    /// - Returns: Void
    public func delete(messageId messageId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}