//
//  ActivityClient.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/5.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit
import ObjectMapper

public enum TypingStatus{
    case StartTyping
    case StopTyping
}

public class ActivityClient: NSObject {

    /// Callback when receive Message.
    ///
    /// - since: 1.4.0
    public var onReceivingMessage:((Activity) -> Void)?
    
    /// Callback when receive start/stop Typing.
    ///
    /// - since: 1.4.0
    public var onReceivingStartorStopTyping:((Activity,TypingStatus) -> Void)?
    
    /// Callback when receive acknowledge activity.
    ///
    /// - since: 1.4.0
    public var onAcknowledgeActivity:((Activity) -> Void)?
    
    
    let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator).path("activities")
    }
    
    private func statusRequestBuilder() ->ServiceRequest.ActivityServerBuilder {
        return ServiceRequest.ActivityServerBuilder(authenticator).path("status")
    }
    
    private func flagRequestBuilder() ->ServiceRequest.RainDropServerBuilder {
        return ServiceRequest.RainDropServerBuilder(authenticator).path("flags")
    }

    /// Lists all messages in a room by room Id.
    /// If present, it includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter conversationId: The identifier of the conversation.
    /// - parameter sinceDate: the activities published date is after this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter midDate: The activities published date is before or after this date. At most limit/2 activities activities before and limit/2 activities after the date will be included, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter maxDate: the activities published date is before this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter limit:  Maximum number of activities return. Default is 6.
    /// - parameter personRefresh: (experimental)control if the person detail in activity need to be refreshed to latest. If person detail got      refreshed, person.id will be in UUID format even if original one is email. Default is false.
    /// - parameter lastActivityFirst: Sort order for the activities. Default is true.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func list(conversationId: String,
                     sinceDate: String? = nil,
                     maxDate: String? = nil,
                     midDate: String? = nil,
                     limit: Int? = nil,
                     personRefresh: Bool? = false,
                     lastActivityFirst: Bool? = false,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<[Activity]>) -> Void)
    {
        let query = RequestParameter([
            "conversationId": conversationId,
            "sinceDate": sinceDate,
            "maxDate": maxDate,
            "maxDate": maxDate,
            "midDate": midDate,
            "limit": limit,
            "personRefresh": personRefresh,
            "lastActivityFirst": lastActivityFirst,
            ])
        
        let request = requestBuilder()
            .method(.get)
            .query(query)
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
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
    public func activityDetail(activityID: String,
                               queue: DispatchQueue? = nil,
                               completionHandler: @escaping (ServiceResponse<Activity>) -> Void)
    {
        let request = requestBuilder()
            .method(.get)
            .path(activityID)
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Posts a plain text message, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the message is to be posted.
    /// - parameter content: The plain text message to be posted to the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func postMessage(conversationID: String,
                            content: String,
                            queue: DispatchQueue? = nil,
                            completionHandler: @escaping (ServiceResponse<Activity>) -> Void)
    {
        let body = RequestParameter([
            "verb": "post",
            "object" : createActivityObject(objectType: "comment",content: content).toJSON(),
            "target" : createActivityTarget(conversationId: conversationID).toJSON()
        ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
         request.responseObject(completionHandler)
    }
    
    /// Deletes a message, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the message is to be posted.
    /// - parameter activityId: The messageId to be deleted in the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func deleteMessage(conversationID: String,
                              activityId: String,
                              queue: DispatchQueue? = nil,
                              completionHandler: @escaping (ServiceResponse<Activity>) -> Void)
    {
        let body = RequestParameter([
            "verb": "delete",
            "object" : createActivityObject(objectType: "activity", objectId:activityId).toJSON(),
            "target" : createActivityTarget(conversationId: conversationID).toJSON()
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Post a message read indicator, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the indicator is to be posted.
    /// - parameter activityId: The activity that is read .
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func read(conversationID: String,
                                  activityId: String,
                                  queue: DispatchQueue? = nil,
                                  completionHandler: @escaping (ServiceResponse<Activity>) -> Void)
    {
        let body = RequestParameter([
            "verb": "acknowledge",
            "object" : createActivityObject(objectType: "activity", objectId:activityId).toJSON(),
            "target" : createActivityTarget(conversationId: conversationID).toJSON()
            ])
        let request = requestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Post a typing indicator, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the indicator is to be posted.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func startTyping(conversationID: String,
                                    queue: DispatchQueue? = nil,
                                    completionHandler: @escaping (ServiceResponse<Any>) -> Void) -> Void
    {
        let body = RequestParameter([
            "eventType": "status.start_typing",
            "conversationId" : conversationID
            ])
        let request = statusRequestBuilder().path("typing")
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseJSON(completionHandler)
    }
    
    /// Post a stop-typing indicator, to a conversation by conversation Id.
    ///
    /// - parameter conversation: The identifier of the conversation where the indicator is to be posted.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func stopTyping(conversationID: String,
                                        queue: DispatchQueue? = nil,
                                        completionHandler: @escaping (ServiceResponse<Any>) -> Void) -> Void
    {
        let body = RequestParameter([
            "eventType": "status.stop_typing",
            "conversationId" : conversationID
            ])
        let request = statusRequestBuilder().path("typing")
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseJSON(completionHandler)
    }
    
    /// Post flag an activity action, to a activity by activity url.
    ///
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func flag(activityUrl: String,
                             queue: DispatchQueue? = nil,
                             completionHandler: @escaping (ServiceResponse<ActivityFlagItem>) -> Void) -> Void
    {
        let body = RequestParameter([
            "flag-item": activityUrl,
            "state": "flagged"
            ])
        
        let request = flagRequestBuilder()
            .method(.post)
            .body(body)
            .queue(queue)
            .build()
        request.responseObject(completionHandler)
    }
    
    /// Post  unflag an activity action, to a flag tem by flagId.
    ///
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func unFlag(flagId: String,
                             queue: DispatchQueue? = nil,
                             completionHandler: @escaping (ServiceResponse<Any>) -> Void) -> Void
    {
        let request = flagRequestBuilder().path(flagId)
            .method(.delete)
            .queue(queue)
            .build()
        request.responseJSON(completionHandler)
    }
    
    /// MARK: private functions
    private func createActivityObject(objectType: String,
                                      objectId: String? = nil ,
                                      content: String? = nil) -> ActivityObjectModel
    {
        var model = ActivityObjectModel()
        model.objectType = objectType
        if let objectIdStr = objectId{
            model.id = objectIdStr
        }
        if let contentStr = content{
            model.content = contentStr
            model.displayName = contentStr
        }
        return model
    }
    
    private func createActivityTarget(conversationId: String? = nil) -> ActivityTargetModel{
        var model = ActivityTargetModel()
        model.objectType = "conversation"
        if let idStr = conversationId{
            model.id = idStr
        }
        return model
    }
}
