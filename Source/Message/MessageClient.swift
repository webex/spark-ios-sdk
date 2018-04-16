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
import Alamofire
import SwiftyJSON


public class MessageClient {
    
    private let phone: Phone
    
    init(phone: Phone) {
        self.phone = phone
    }
    
    /// Lists all messages in a room by room's Id.
    /// If present, it includes the associated media content attachment for each message.
    /// The list sorts the messages in descending order by creation date.
    ///
    /// - parameter roomId: The identifier of the room.
    /// - parameter sinceDate: the messages published date is after this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter midDate: The messages published date is before or after this date. At most limit/2 messages before and limit/2 messages after the date will be included, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter maxDate: the messages published date is before this date, format in "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    /// - parameter limit:  Maximum number of messages return. Default is 6.
    /// - parameter personRefresh: (experimental)control if the person detail in message need to be refreshed to latest. If person detail got      refreshed, person.id will be in UUID format even if original one is email. Default is false.
    /// - parameter lastMessageFirst: Sort order for the messages. Default is true.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func list(roomId: String,
                     sinceDate: String? = nil,
                     maxDate: String? = nil,
                     midDate: String? = nil,
                     limit: Int? = nil,
                     personRefresh: Bool? = false,
                     lastMessageFirst: Bool? = true,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<[Message]>) -> Void) {
        self.phone.doSomethingAfterRegistered { error in
            if let impl = self.phone.messages {
                impl.list(roomId: roomId, sinceDate: sinceDate, maxDate: maxDate, midDate: midDate, limit: limit, personRefresh: personRefresh, lastMessageFirst: lastMessageFirst, queue: queue, completionHandler: completionHandler)
            }
            else {
                (queue ?? DispatchQueue.main).async {
                    completionHandler(ServiceResponse(nil, Result.failure(error ?? SparkError.unregistered)))
                }
            }
        }
    }
    
    /// Detail of one message.
    ///
    /// - parameter messageID: The identifier of the message.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.2.0
    public func get(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        self.phone.doSomethingAfterRegistered { error in
            if let impl = self.phone.messages {
                impl.get(messageId: messageId, queue: queue, completionHandler: completionHandler)
            }
            else {
                (queue ?? DispatchQueue.main).async {
                    completionHandler(ServiceResponse(nil, Result.failure(error ?? SparkError.unregistered)))
                }
            }
        }
    }
    
    /// Posts a plain text message to a room by user email
    ///
    /// - parameter email: The email of the user where the message is to be posted.
    /// - parameter content: The plain text message to be posted to the room.
    /// - parameter medtions: The mention items to be posted to the room.
    /// - parameter files: local file pathes to be uploaded to the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func post(email: String,
                     text: String? = nil,
                     mentions: [Mention]? = nil,
                     files: [LocalFile]? = nil,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        self.phone.doSomethingAfterRegistered { error in
            if let impl = self.phone.messages {
                impl.post(email: email, text: text, mentions: mentions, files: files, queue: queue, completionHandler: completionHandler)
            }
            else {
                (queue ?? DispatchQueue.main).async {
                    completionHandler(ServiceResponse(nil, Result.failure(error ?? SparkError.unregistered)))
                }
            }
        }
    }
    
    /// Posts a plain text message, to a room by roomId.
    ///
    /// - parameter roomId: The identifier of the room where the message is to be posted.
    /// - parameter content: The plain text message to be posted to the room.
    /// - parameter medtions: The mention items to be posted to the room.
    /// - parameter files: local file pathes to be uploaded to the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func post(roomId: String,
                     text: String? = nil,
                     mentions: [Mention]? = nil,
                     files: [LocalFile]? = nil,
                     queue: DispatchQueue? = nil,
                     completionHandler: @escaping (ServiceResponse<Message>) -> Void) {
        self.phone.doSomethingAfterRegistered { error in
            if let impl = self.phone.messages {
                impl.post(roomId: roomId, text: text, mentions: mentions, files: files, queue: queue, completionHandler: completionHandler)
            }
            else {
                (queue ?? DispatchQueue.main).async {
                    completionHandler(ServiceResponse(nil, Result.failure(error ?? SparkError.unregistered)))
                }
            }
        }
    }
    
    /// Deletes a message, to a room by roomId.
    ///
    /// - parameter roomId: The identifier of the room where the message is to be posted.
    /// - parameter messageId: The messageId to be deleted in the room.
    /// - parameter queue: If not nil, the queue on which the completion handler is dispatched. Otherwise, the handler is dispatched on the application's main thread.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    /// - returns: Void
    /// - since: 1.4.0
    public func delete(messageId: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        self.phone.doSomethingAfterRegistered { error in
            if let impl = self.phone.messages {
                impl.delete(messageId: messageId, queue: queue, completionHandler: completionHandler)
            }
            else {
                (queue ?? DispatchQueue.main).async {
                    completionHandler(ServiceResponse(nil, Result.failure(error ?? SparkError.unregistered)))
                }
            }
        }
    }
    
    /// Download a file object, download both file body / thumbnail if exist.
    ///
    /// - parameter roomId: The identifier of the room where the fike is fetched.
    /// - parameter file: file object.
    /// - parameter progressHandler: the download progress indicator.
    /// - parameter completionHandler: downloaded file local address wiil be stored in "file.localFileUrl"
    /// - returns: Void
    /// - since: 1.4.0
    public func downloadFile(file: RemoteFile, to: URL? = nil, progressHandler: ((Double)->Void)? = nil, completionHandler: @escaping (Result<URL>) -> Void) {
        self.phone.doSomethingAfterRegistered { error in
            if let impl = self.phone.messages {
                impl.downloadFile(file: file, to: to, progressHandler: progressHandler, completionHandler: completionHandler)
            }
            else {
                (DispatchQueue.main).async {
                    completionHandler(Result.failure(error ?? SparkError.unregistered))
                }
            }
        }
    }
    
    /// Download a file object, download both file thumbnail only if exist.
    ///
    /// - parameter roomId: The identifier of the room where the fike is fetched.
    /// - parameter file: file object.
    /// - parameter progressHandler: the download progress indicator.
    /// - parameter completionHandler: downloaded file local address wiil be stored in "file.localFileUrl"
    /// - returns: Void
    /// - since: 1.4.0
    public func downloadThumbnail(file: RemoteFile, to: URL? = nil, progressHandler: ((Double)->Void)? = nil, completionHandler: @escaping (Result<URL>) -> Void) {
        self.phone.doSomethingAfterRegistered { error in
            if let impl = self.phone.messages {
                impl.downloadThumbnail(file: file, to: to, progressHandler: progressHandler, completionHandler: completionHandler)
            }
            else {
                (DispatchQueue.main).async {
                    completionHandler(Result.failure(error ?? SparkError.unregistered))
                }
            }
        }
    }
}


