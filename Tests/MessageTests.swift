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
import XCTest
@testable import SparkSDK

class MessageTests: XCTestCase {
    
    private let text = "test text"
    private let fileUrl = "https://developer.ciscospark.com/index.html"
    private var fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private var other: TestUser!
    private var messages: MessageClient!
    private var roomId: String!
    
    private func getISO8601Date() -> String {
        
        return getISO8601DateWithDate(Date())
    }
    
    private func getISO8601DateWithDate(_ date:Date) -> String {
        let formatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        formatter.locale = enUSPosixLocale
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        return formatter.string(from: date)
    }

    
    private func validate(message: Message?) {
        XCTAssertNotNil(message)
        XCTAssertNotNil(message?.id)
        XCTAssertNotNil(message?.personId)
        XCTAssertNotNil(message?.personEmail)
        XCTAssertNotNil(message?.roomId)
        XCTAssertNotNil(message?.created)
    }
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        if other == nil {
            other = fixture.createUser()
        }
        messages = fixture.spark.messages
        let room = fixture.createRoom(testCase: self, title: "test room")
        XCTAssertNotNil(room?.id)
        roomId = room?.id
    }
    
    override func tearDown() {
        if let roomId = roomId {
            fixture.deleteRoom(testCase: self, roomId: roomId)
        }
    }
    
    override static func tearDown() {
        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
        super.tearDown()
    }
    
    func testPostingMessageToRoomWithTextReturnsMessage() {
        let message = postMessage(roomId: roomId, text: text, files: nil)
        validate(message: message)
        XCTAssertEqual(message?.text, text)
    }
    
    func testPostingMessageToRoomWithFileReturnsMessage() {
        let message = postMessage(roomId: roomId, files: fileUrl)
        validate(message: message)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageToRoomWithTextAndFileReturnsMessage() {
        let message = postMessage(roomId: roomId, text: text, files: fileUrl)
        validate(message: message)
        XCTAssertEqual(message?.text, text)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageToInvalidRoomDoesNotReturnMessage() {
        let message = postMessage(roomId: Config.InvalidId, text: text, files: fileUrl)
        XCTAssertNil(message)
    }
    
    func testPostingMessageUsingPersonIdWithTextReturnsMessage() {
        let message = postMessage(personId: other.personId, text: text, files: nil)
        validate(message: message)
        XCTAssertEqual(message?.toPersonId, other.personId)
        XCTAssertEqual(message?.text, text)
    }
    
    func testPostingMessageUsingPersonIdWithFileReturnsMessage() {
        let message = postMessage(personId: other.personId, files: fileUrl)
        validate(message: message)
        XCTAssertEqual(message?.toPersonId, other.personId)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageUsingPersonIdWithTextAndFileReturnsMessage() {
        let message = postMessage(personId: other.personId, text: text, files: fileUrl)
        validate(message: message)
        XCTAssertEqual(message?.toPersonId, other.personId)
        XCTAssertEqual(message?.text, text)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageUsingInvalidPersonIdDoesNotReturnMessage() {
        let message = postMessage(personId: Config.InvalidId, text: text, files: fileUrl)
        XCTAssertNil(message)
    }
    
    func testPostingMessageUsingPersonEmailWithTextReturnsMessage() {
        let message = postMessage(personEmail: other.email, text: text, files: nil)
        validate(message: message)
        XCTAssertEqual(message?.toPersonEmail, other.email)
        XCTAssertEqual(message?.text, text)
    }
    
    func testPostingMessageUsingPersonEmailWithFileReturnsMessage() {
        let message = postMessage(personEmail: other.email, files: fileUrl)
        validate(message: message)
        XCTAssertEqual(message?.toPersonEmail, other.email)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageUsingPersonEmailWithTextAndFileReturnsMessage() {
        let message = postMessage(personEmail: other.email, text: text, files: fileUrl)
        validate(message: message)
        XCTAssertEqual(message?.toPersonEmail, other.email)
        XCTAssertEqual(message?.text, text)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageUsingInvalidPersonEmailReturnsMessage() {
        let message = postMessage(personEmail: Config.InvalidEmail, text: text, files: fileUrl)
        XCTAssertNotNil(message)
    }
    
    func testListingMessagesReturnsMessages() {
        _ = postMessage(roomId: roomId, text: text, files: nil)
        let messageArray = listMessages(roomId: roomId, before: nil, beforeMessage: nil, max: nil)
        XCTAssertEqual(messageArray?.isEmpty, false)
    }
    
    func testListingMessagesWithMaxValueOf2ReturnsOnly2Messages() {
        _ = postMessage(roomId: roomId, text: text, files: nil)
        _ = postMessage(roomId: roomId, text: text, files: nil)
        _ = postMessage(roomId: roomId, text: text, files: nil)
        let messageArray = listMessages(roomId: roomId, before: nil, beforeMessage: nil, max: 2)
        XCTAssertEqual(messageArray?.count, 2)
    }
    
    func testListingMessagesBeforeADateReturnsMessagesPostedBeforeThatDate() {
        let message1 = postMessage(roomId: roomId, text: text, files: nil)
        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
        var nowDate = Date()
        if let createDate = message1?.created,nowDate > createDate.addingTimeInterval(Config.TestcaseInterval){
                nowDate = createDate.addingTimeInterval(Config.TestcaseInterval)
        }
        let now = getISO8601DateWithDate(nowDate)
        
        let message2 = postMessage(roomId: roomId, text: text, files: nil)
        let messageArray = listMessages(roomId: roomId, before: now, beforeMessage: nil, max: nil)
        XCTAssertEqual(messageArray?.contains() {$0.id == message1?.id}, true)
        XCTAssertEqual(messageArray?.contains() {$0.id == message2?.id}, false)
    }
    
    func testListingMessagesPostedBeforeAMessageIdReturnsOnlyMessagesPostedBeforeThatMessage() {
        let message1 = postMessage(roomId: roomId, text: text, files: nil)
        let message2 = postMessage(roomId: roomId, text: text, files: nil)
        let messageArray = listMessages(roomId: roomId, before: nil, beforeMessage: message2?.id, max: nil)
        XCTAssertEqual(messageArray?.contains() {$0.id == message1?.id}, true)
        XCTAssertEqual(messageArray?.contains() {$0.id == message2?.id}, false)
    }
    
    func testListingMessagesBeforeADateAndAMessageIdDoesNotReturnMessageWithThatId() {
        let message = postMessage(roomId: roomId, text: text, files: nil)
        let now = self.getISO8601Date()
        let messageArray = listMessages(roomId: roomId, before: now, beforeMessage: message?.id, max: nil)
        XCTAssertEqual(messageArray?.contains() {$0.id == message?.id}, false)
    }
    
    func testListingMessageWithInvalidRoomIdDoesNotReturnMessage() {
        let messageArray = listMessages(roomId: Config.InvalidId, before: nil, beforeMessage: nil, max: nil)
        XCTAssertNil(messageArray)
    }
    
    func testGettingMessageReturnsMessage() {
        let messageFromCreate = postMessage(roomId: roomId, text: text, files: fileUrl)
        validate(message: messageFromCreate)
        if let messageFromCreateId = messageFromCreate?.id {
            let messageFromGet = getMessage(messageId: messageFromCreateId)
            validate(message: messageFromGet)
            XCTAssertEqual(messageFromGet?.id, messageFromCreate?.id)
            XCTAssertEqual(messageFromGet?.text, messageFromCreate?.text)
        } else {
            XCTFail("Failed to get message")
        }
    }
    
    func testGettingMessageWithInvalidMessageIdFails() {
        let message = getMessage(messageId: Config.InvalidId)
        XCTAssertNil(message)
    }
    
    func testDeletingMessageRemovesMessageAndItCanNoLongerBeRetrieved() {
        let message = postMessage(roomId: roomId, text: text, files: nil)
        XCTAssertNotNil(message?.id)
        let messageId = message?.id
        XCTAssertTrue(deleteMessage(messageId: messageId!))
        XCTAssertNil(getMessage(messageId: messageId!))
    }
    
    func testDeletingMessageWithBadIdFails() {
        XCTAssertFalse(deleteMessage(messageId: Config.InvalidId))
    }
    
    func testSendListDeleteMessage() {
        let message1 = postMessage(roomId: roomId, text: text, files: nil)
        let message2 = postMessage(roomId: roomId, text: text, files: nil)
        let message3 = postMessage(roomId: roomId, text: text, files: fileUrl)
        XCTAssertEqual(message1?.text, text)
        XCTAssertEqual(message2?.text, text)
        XCTAssertEqual(message3?.text, text)
        XCTAssertNotNil(message3?.files)
        
        let messageArray = listMessages(roomId: roomId, before: nil, beforeMessage: nil, max: 3)
        XCTAssertEqual(messageArray?.count, 3)
        
        
        XCTAssertTrue(deleteMessage(messageId: message2!.id!))
        let messageArray1 = listMessages(roomId: roomId, before: nil, beforeMessage: nil, max: 3)
        XCTAssertEqual(messageArray1?.count, 2)
        XCTAssertEqual(messageArray1?.filter(){$0.id == message2!.id}.count, 0)
        
        XCTAssertTrue(deleteMessage(messageId: message3!.id!))
        let messageArray2 = listMessages(roomId: roomId, before: nil, beforeMessage: nil, max: 3)
        XCTAssertEqual(messageArray2?.count, 1)
    }
    
    
    private func deleteMessage(messageId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Any>) -> Void) in
            self.messages.delete(messageId: messageId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request) != nil
    }
    
    private func postMessage(roomId: String, text: String, files: String?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(roomId: roomId, text: text, files: files, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(roomId: String, files: String) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(roomId: roomId, files: files, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personId: String, text: String, files: String?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(personId: personId, text: text, files: files, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personId: String, files: String) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(personId: personId, files: files, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personEmail: EmailAddress, text: String, files: String?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(personEmail: personEmail, text: text, files: files, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personEmail: EmailAddress, files: String) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(personEmail: personEmail, files: files, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func listMessages(roomId: String, before: String?, beforeMessage: String?, max: Int?) -> [Message]? {
        let request = { (completionHandler: @escaping (ServiceResponse<[Message]>) -> Void) in
            self.messages.list(roomId: roomId, before: before, beforeMessage: beforeMessage, max: max, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func getMessage(messageId: String) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.get(messageId: messageId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
}


