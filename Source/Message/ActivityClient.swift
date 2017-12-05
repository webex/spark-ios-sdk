//
//  ActivityClient.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/5.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit
import ObjectMapper

public class ActivityClient: NSObject {
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator).path("activities")
    }
    
    /// Lists all messages in a room by room Id.
    /// If present, it includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter activityID: The identifier of the activity.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func detail(activityID: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Activity>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .path(activityID)
            .build()
        request.responseObject(completionHandler)
    }
    
    public func postMessage(conversationID: String, content: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Activity>) -> Void){
        
        let body = RequestParameter([
            "verb": "post",
            "object" : createActivityObjectWith(content: content).toJSONString(prettyPrint: true),
            "target" : createActivityTargetWith(conversationId: conversationID).toJSONString(prettyPrint: true)
        ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .build()
         request.responseObject(completionHandler)
    }
    
    
    /// Posts a plain text message, and optionally, a media content attachment, to a room by room Id.
    ///
    /// - parameter roomId: The identifier of the room where the message is to be posted.
    /// - parameter text: The plain text message to be posted to the room.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(roomId: String, text: String, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        post(roomId: roomId, personId: nil, personEmail: nil, text: text, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a media content attachment to a room by room Id without text.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(roomId: String, files: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        post(roomId: roomId, personId: nil, personEmail: nil, text: nil, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a private 1:1 message in plain text, and optionally, a media content attachment, to a person by person Id.
    ///
    /// - parameter personId: The identifier of the recipient of this private 1:1 message.
    /// - parameter text: The plain text message to post to the recipient.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark  downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personId: String, text: String, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        post(roomId: nil, personId: personId, personEmail: nil, text: text, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a media content attachment to a person by person Id without text.
    ///
    /// - parameter personId: The identifier of the recipient of this media content.
    /// - parameter files: A public URL that Cisco Spark can use to fetch attachments. Currently supports only a single URL. Cisco Spark  downloads the content from the URL one time shortly after the message is created and automatically converts it to a format that all Cisco Spark clients can render.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personId: String, files: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        post(roomId: nil, personId: personId, personEmail: nil, text: nil, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a private 1:1 message in plain text, and optionally, a media content attachment, to a person by person Id.
    ///
    /// - parameter personEmail: The email address of the recipient when sending a private 1:1 message.
    /// - parameter text: The plain text message to post to the room.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personEmail: EmailAddress, text: String, files: String? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        post(roomId: nil, personId: nil, personEmail: personEmail, text: text, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    /// Posts a media content attachment to a person by email address without text.
    ///
    /// - parameter personEmail: The email address of the recipient of this media content.
    /// - parameter files: A public URL that Spark can use to fetch attachments. Currently supports only a single URL. The Spark Cloud downloads the content one time shortly after the message is created and automatically converts it to a format that all Spark clients can render.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func post(personEmail: EmailAddress, files: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        post(roomId: nil, personId: nil, personEmail: personEmail, text: nil, files: files, queue: queue, completionHandler: completionHandler)
    }
    
    private func post(roomId: String?, personId: String?, personEmail: EmailAddress?, text: String?, files: String?, queue: DispatchQueue?, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
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
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void){
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
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func delete(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = requestBuilder()
            .method(.delete)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    
    
    private func createActivityObjectWith(content: String? = nil) -> ActivityObjectModel{
        var model = ActivityObjectModel()
        if let contentStr = content{
            model.content = contentStr
        }
        return model
    }
    
    private func createActivityTargetWith(conversationId: String? = nil) -> ActivityTargetModel{
        var model = ActivityTargetModel()
        if let idStr = conversationId{
            model.id = idStr
        }
        return model
    }
}
