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

/// Message HTTP client.
open class MessageClient: CompletionHandlerType<Message> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("messages")
    }
    
    /// Lists all messages in a room. If present, includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter roomId: List messages for a room by id.
    /// - parameter before: List messages sent before a date and time, in ISO8601 format.
    /// - parameter beforeMessage: List messages sent before a message by id.
    /// - parameter max: Limit the maximum number of messages in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func list(roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: ArrayHandler) {
        let query = RequestParameter([
            "roomId": roomId,
            "before": before,
            "beforeMessage": beforeMessage,
            "max": max])
        
        let request = requestBuilder()
            .method(.get)
            .query(query)
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a room.
    ///
    /// - parameter roomId: The room id.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func postTo(roomId: String, text: String? = nil, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
            "roomId": roomId,
            "text": text,
            "files": files])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a person.
    ///
    /// - parameter personId: The id of the recipient when sending a private1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func postTo(personId: String, text: String? = nil, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
            "toPersonId": personId,
            "text": text,
            "files": files])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Posts a plain text message, and optionally, a media content attachment, to a person.
    ///
    /// - parameter personEmail: The email address of the recipient when sendinga private 1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func postTo(personEmail: EmailAddress, text: String? = nil, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: ObjectHandler) {
        let body = RequestParameter([
            "toPersonEmail": personEmail.toString(),
            "text": text,
            "files": files])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Shows details for a message by message id.
    ///
    /// - parameter messageId: The message id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func get(messageId: String, queue: DispatchQueue? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.get)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a message by message id.
    ///
    /// - parameter messageId: The message id.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    open func delete(messageId: String, queue: DispatchQueue? = nil, completionHandler: AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
