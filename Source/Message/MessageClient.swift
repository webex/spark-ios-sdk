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

/// An iOS client wrapper of the Cisco Spark [Messages REST API](https://developer.ciscospark.com/resource-messages.html) .
///
/// - since: 1.2.0
public class MessageClient {
    
    /// Alias for closure to handle a service response along with a Message object.
    ///
    /// - since: 1.2.0
    public typealias ObjectHandler = (ServiceResponse<Message>) -> Void
    
    /// Alias for closure to handle a service response along with a Message array.
    ///
    /// - since: 1.2.0
    public typealias ArrayHandler = (ServiceResponse<[Message]>) -> Void
    
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).path("messages")
    }
    
    /// Lists all messages in a room by room Id.
    /// If present, it includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter before: If not nil, only list messages sent only before this date and time, in ISO8601 format.
    /// - parameter beforeMessage: if not nil, only list messages sent only before this message by id.
    /// - parameter max: The maximum number of messages in the response.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func list(roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
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
    
    /// Posts a plain text message, and optionally, a media content attachment, to a room by room Id.
    ///
    /// - parameter roomId: The identifier of the room where the message is to be posted.
    /// - parameter text: The plain text message to be posted to the room.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(roomId: String, text: String, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        post(roomId: roomId, personId: nil, personEmail: nil, text: text, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a media content attachment to a room by room Id without text.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(roomId: String, files: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        post(roomId: roomId, personId: nil, personEmail: nil, text: nil, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a private 1:1 message in plain text, and optionally, a media content attachment, to a person by person Id.
    ///
    /// - parameter personId: The identifier of the recipient of this private 1:1 message.
    /// - parameter text: The plain text message to post to the recipient.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark  downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personId: String, text: String, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        post(roomId: nil, personId: personId, personEmail: nil, text: text, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a media content attachment to a person by person Id without text.
    ///
    /// - parameter personId: The identifier of the recipient of this media content.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark  downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personId: String, files: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        post(roomId: nil, personId: personId, personEmail: nil, text: nil, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a private 1:1 message in plain text, and optionally, a media content attachment, to a person by person Id.
    ///
    /// - parameter personEmail: The email address of the recipient when sending a private 1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personEmail: EmailAddress, text: String, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        post(roomId: nil, personId: nil, personEmail: personEmail, text: text, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a media content attachment to a person by email address without text.
    ///
    /// - parameter personEmail: The email address of the recipient of this media content.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personEmail: EmailAddress, files: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        post(roomId: nil, personId: nil, personEmail: personEmail, text: nil, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    private func post(roomId: String?, personId: String?, personEmail: EmailAddress?, text: String?, files: String?, queue: DispatchQueue?, completionHandler: @escaping ObjectHandler) {
        let email: String? = personEmail == nil ? nil : personEmail!.toString()
        let body = RequestParameter([
            "roomId": roomId,
            "toPersonId": personId,
            "toPersonEmail": email,
            "text": text,
            "files": files])
        
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Retrieves the details for a message by message Id.
    ///
    /// - parameter messageId: The identifier of the message.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler){
        let request = requestBuilder()
            .method(.get)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    /// Deletes a message by message id.
    ///
    /// - parameter messageId: The identifier of the message.
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func delete(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.delete)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
