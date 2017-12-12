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


public class ActivityClient {

    /// Callback when receive Message.
    ///
    /// - since: 1.4.0
    public var onMessageActivity:((MessageActivity) -> Void)?

    /// Callback when receive acknowledge activity.
    ///
    /// - since: 1.4.0
    public var onTypingActivity:((TypingActivity) -> Void)?

    /// Callback when delete Message.
    ///
    /// - since: 1.4.0
    public var onFlagActivity:((FlagActivity) -> Void)?
    
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
    public func listMessageActivities(conversationId: String,
                     sinceDate: String? = nil,
                     maxDate: String? = nil,
                     midDate: String? = nil,
                     limit: Int? = nil,
                     personRefresh: Bool? = false,
                     lastActivityFirst: Bool? = false,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<[MessageActivity]>) -> Void)
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
    
    /// Detail of one messate activity.
    ///
    /// - parameter activityID: The identifier of the activity.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func messageActivityDetail(activityID: String,
                               queue: DispatchQueue? = nil,
                               completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
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
                            mentions: [ActivityMentionModel]? = nil,
                            queue: DispatchQueue? = nil,
                            completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        let body = RequestParameter([
            "verb": "post",
            "object" : createActivityObject(objectType: "comment",content: content,mentions: mentions).toJSON(),
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
                              messageActivityId: String,
                              queue: DispatchQueue? = nil,
                              completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        let body = RequestParameter([
            "verb": "delete",
            "object" : createActivityObject(objectType: "activity", objectId:messageActivityId).toJSON(),
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
                                  massageActivityId: String,
                                  queue: DispatchQueue? = nil,
                                  completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void)
    {
        let body = RequestParameter([
            "verb": "acknowledge",
            "object" : createActivityObject(objectType: "activity", objectId:massageActivityId).toJSON(),
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
    public func flag(flagItemUrl: String,
                             queue: DispatchQueue? = nil,
                             completionHandler: @escaping (ServiceResponse<FlagActivity>) -> Void) -> Void
    {
        let body = RequestParameter([
            "flag-item": flagItemUrl,
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
    public func unFlag(flagItemId: String,
                             queue: DispatchQueue? = nil,
                             completionHandler: @escaping (ServiceResponse<Any>) -> Void) -> Void
    {
        let request = flagRequestBuilder().path(flagItemId)
            .method(.delete)
            .queue(queue)
            .build()
        request.responseJSON(completionHandler)
    }
    
    
    
    /// MARK: client private functions
    private func createActivityObject(objectType: String,
                                      objectId: String? = nil ,
                                      content: String? = nil,
                                      mentions: [ActivityMentionModel]? = nil) -> ActivityObjectModel
    {
        var model = ActivityObjectModel()
        model.objectType = objectType
        if let objectIdStr = objectId{
            model.id = objectIdStr
        }
        if let contentStr = content{
            var markedUpContent = contentStr
            if let mentionsArr = mentions{
                var mentionStringLength = 0
                for index in 0..<mentionsArr.count{
                    let mentionItem = mentionsArr[index]
                    if(mentionItem.mentionType == MentionItemType.person){
                        let startPosition = (mentionItem.range.lowerBound) + mentionStringLength
                        let endPostion = (mentionItem.range.upperBound) + mentionStringLength
                        let startIndex = markedUpContent.index(markedUpContent.startIndex, offsetBy: startPosition)
                        let endIndex = markedUpContent.index(markedUpContent.startIndex, offsetBy: endPostion)
                        let mentionContent = markedUpContent[startPosition..<endPostion]
                        let markupStr = markUpString(mentionContent: mentionContent, mentionId: mentionItem.id, mentionType: "person")
                        markedUpContent = markedUpContent.replacingCharacters(in: startIndex..<endIndex, with: markupStr)
                        mentionStringLength += (markupStr.count - mentionContent.count) + 1
                    }else{
                        /// group mention codes goes heere
                    }
                }
                model.content = markedUpContent
                model.displayName = contentStr
                model.mentions =  ["items" : mentionsArr]
            }else{
                model.content = contentStr
                model.displayName = contentStr
            }
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
    
    private func markUpString(mentionContent: String?, mentionId: String?, mentionType: String?)->String{
        var result = "<spark-mention"
        if let mentionid = mentionId{
            result = result + " data-object-id=" + mentionid
        }
        if let type = mentionType{
            result = result + " data-object-type=" + type
        }
        result = result + ">"
        if let content = mentionContent{
            result = result + content
        }
        result = result + "</spark-mention>"
        return result
    }
}
