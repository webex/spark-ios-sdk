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
        XCTAssertNotNil(message?.actor)
        XCTAssertNotNil(message?.roomId)
        XCTAssertNotNil(message?.publishedDate)
    }
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        if other == nil {
            other = fixture.createUser()
        }
        XCTAssertTrue(registerPhone())
        self.messages = self.fixture.spark.messages
        let room = self.fixture.createRoom(testCase: self, title: "test room")
        XCTAssertNotNil(room?.id)
        self.roomId = room?.id
    }

    override func tearDown() {
        XCTAssertTrue(deregisterPhone())
        if let roomId = roomId {
            fixture.deleteRoom(testCase: self, roomId: roomId)
        }
        
    }
    
    override static func tearDown() {
        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
        super.tearDown()
    }
    
    private func registerPhone() -> Bool {
        let phone = fixture.spark.phone
        var success = false
        let expect = expectation(description: "Phone registration")
        phone.register() { error in
            success = (error == nil)
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone registration timed out")
        }
        return success
    }
    
    private func deregisterPhone() -> Bool {
        let phone = fixture.spark.phone
        var success = false
        
        let expect = expectation(description: "Phone deregistration")
        phone.deregister() { error in
            success = (error == nil)
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Phone deregistration timed out")
        }
        
        return success
    }
    
    func testPostingMessageToRoomWithTextReturnsMessage() {
        let message = postMessage(conversationId: roomId, text: text, mentions: nil, files:nil)
        validate(message: message)
        XCTAssertEqual(message?.plainText, text)
    }
    
    func testPostingMessageToRoomWithFileReturnsMessage() {
        let file = FileObjectModel(name: "sample.png", localFileUrl: self.generateLocalFile()!)
        let message = postMessage(conversationId: roomId,files: [file])
        validate(message: message)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageWithTextAndMentionReturnsMessage(){
        let mentionItem = MessageMentionModel(range: 0...3 , personId: Config.InvalidId, type: MentionItemType.person)
        let message = postMessage(conversationId: roomId, text: text, mentions:[mentionItem], files: nil)
        validate(message: message)
        XCTAssertEqual(message?.plainText, text)
    }

    func testPostingMessageToRoomWithTextAndFileReturnsMessage() {
        let file = FileObjectModel(name: "sample.png", localFileUrl: self.generateLocalFile()!)
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: [file])
        validate(message: message)
        XCTAssertEqual(message?.plainText, text)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageToRoomWithTextAndFileAndMentionReturnsMessage(){
        let file = FileObjectModel(name: "sample.png", localFileUrl: self.generateLocalFile()!)
        let mentionItem = MessageMentionModel(range: 0...3, personId: Config.InvalidId, type: MentionItemType.person)
        let message = postMessage(conversationId: roomId, text: text, mentions:[mentionItem], files: [file])
        validate(message: message)
        XCTAssertEqual(message?.plainText, text)
        XCTAssertNotNil(message?.files)
    }

    func testPostingMessageToRoomWithInvalidFileNotReturnMessage(){
        let file = FileObjectModel(name: "sample.png", localFileUrl: Config.InvalidLocalAddress)
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: [file])
        XCTAssertNil(message)
    }

    func testPostingMessageToInvalidRoomDoesNotReturnMessage() {
        let message = postMessage(conversationId: Config.InvalidId, text: text, mentions:nil, files: nil)
        XCTAssertNil(message)
    }

    func testPostingMessageUsingPersonEmailWithTextReturnsMessage() {
        let message = postMessage(personEmail: other.email, text: text, files: nil)
        validate(message: message)
        XCTAssertEqual(message?.plainText, text)
    }
    
    func testPostingMessageUsingPersonEmailWithFileReturnsMessage() {
        let file = FileObjectModel(name: "sample.png", localFileUrl: self.generateLocalFile()!)
        let message = postMessage(personEmail: other.email, text: "", files: [file])
        validate(message: message)
        XCTAssertNotNil(message?.files)
    }

    func testPostingMessageUsingPersonEmailWithTextAndFileReturnsMessage() {
        let file = FileObjectModel(name: "sample.png", localFileUrl: self.generateLocalFile()!)
        let message = postMessage(personEmail: other.email, text: text, files: [file])
        validate(message: message)
        XCTAssertEqual(message?.plainText, text)
        XCTAssertNotNil(message?.files)
    }
    
//    func testPostingMessageUsingInvalidPersonEmailReturnsMessage() {
//        if let message = postMessage(personEmail: Config.InvalidEmail, text: text, files: nil){
//            XCTAssertNotNil(message)
//        }else{
//            XCTAssertNil(nil)
//        }
//
//    }
    
    func testFlagMessageRetrunsFlagMessages(){
        let message = postMessage(personEmail: other.email, text: text, files:nil)
        let flagMessage = self.flagMessage(messageUrl: (message?.url)!)
        XCTAssertNotNil(flagMessage)
    }
    
    func testUnFlagMessageReturnSuccess(){
        let message = postMessage(personEmail: other.email, text: text, files:nil)
        let flagItem = self.flagMessage(messageUrl: (message?.url)!)
        XCTAssertNotNil(flagItem)
        self.messages.unFlag(flagId: (flagItem?.id)!) { (response) in
            switch response.result{
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testStartTyingAndStopTypingReturnSuccess(){
        self.messages.startTyping(roomId: roomId) { (response) in
            switch response.result{
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTAssertTrue(false)
            }
        }
        
        self.messages.stopTyping(roomId: roomId) { (response) in
            switch response.result{
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testDeleteMessageReturnSuccess(){
        let message = postMessage(personEmail: other.email, text: text, files:nil)
        validate(message: message)
        self.messages.delete(roomId: roomId, messageId: (message?.id)!) { (response) in
            switch response.result{
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    func testGetMessageReturnSuccess(){
        let message = postMessage(personEmail: other.email, text: text, files:nil)
        validate(message: message)
        self.messages.get(messageID: (message?.id)!) { (response) in
            switch response.result{
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testListingMessagesReturnsMessages() {
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        validate(message: message)
        let messageArray = listMessages(conversationId: roomId, sinceDate: nil, maxDate: nil, midDate: nil, limit: nil, personRefresh: nil)
        XCTAssertEqual(messageArray?.isEmpty, false)
    }
    
    func testListingMessagesWithMaxValueOf2ReturnsOnly2Messages() {
        _ = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        _ = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        _ = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let messageArray = listMessages(conversationId: roomId, sinceDate: nil, maxDate: nil, midDate: nil, limit: 2, personRefresh: false)
        XCTAssertEqual(messageArray?.count, 2)
    }
    
    func testListingMessagesBeforeADateReturnsMessagesPostedBeforeThatDate() {
        let message1 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        Thread.sleep(forTimeInterval: 5)
        var nowDate = Date()
        if let createDate = message1?.publishedDate,nowDate > createDate.addingTimeInterval(Config.TestcaseInterval){
                nowDate = createDate.addingTimeInterval(Config.TestcaseInterval)
        }
        let now = getISO8601DateWithDate(nowDate)
        
        let message2 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let messageArray = listMessages(conversationId: roomId, sinceDate: nil, maxDate: now, midDate: nil, limit: nil, personRefresh: nil)
        XCTAssertEqual(messageArray?.contains() {$0.id == message1?.id}, true)
        XCTAssertEqual(messageArray?.contains() {$0.id == message2?.id}, false)
    }
    
    func testListingMessagesBeforeADateAndAMessageIdDoesNotReturnMessageWithThatId() {
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let now = self.getISO8601Date()
        let messageArray = listMessages(conversationId: roomId, sinceDate: now, maxDate: nil, midDate: nil, limit: nil, personRefresh: nil)
        XCTAssertEqual(messageArray?.contains() {$0.id == message?.id}, false)
    }
    
    func testListingMessageWithInvalidRoomIdDoesNotReturnMessage() {
        let messageArray = listMessages(conversationId: Config.InvalidId, sinceDate: nil, maxDate: nil, midDate: nil, limit: nil, personRefresh: nil)
        XCTAssertNil(messageArray)
    }
    
    func testGettingMessageReturnsMessage() {
        let messageFromCreate = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        validate(message: messageFromCreate)
        if let messageFromCreateId = messageFromCreate?.id {
            let messageFromGet = getMessage(messageId: messageFromCreateId)
            validate(message: messageFromGet)
            XCTAssertEqual(messageFromGet?.id, messageFromCreate?.id)
            XCTAssertEqual(messageFromGet?.plainText, messageFromCreate?.plainText)
        } else {
            XCTFail("Failed to get message")
        }
    }
    
    func testGettingMessageWithInvalidMessageIdFails() {
        let message = getMessage(messageId: Config.InvalidId)
        XCTAssertNil(message)
    }
    
    func testDeletingMessageRemovesMessageAndItCanNoLongerBeRetrieved() {
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        XCTAssertNotNil(message?.id)
        let messageId = message?.id
        XCTAssertTrue(deleteMessage(messageId: messageId!))
        XCTAssertEqual(getMessage(messageId: messageId!)?.action, MessageAction.tombstone)
    }
    
    func testDeletingMessageWithBadIdFails() {
        XCTAssertFalse(deleteMessage(messageId: Config.InvalidId))
    }
    
    func testSendListDeleteMessage() {
        let message1 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message2 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message3 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        XCTAssertEqual(message1?.plainText, text)
        XCTAssertEqual(message2?.plainText, text)
        XCTAssertEqual(message3?.plainText, text)
        XCTAssertNil(message3?.files)
        
        let messageArray = listMessages(conversationId: roomId, sinceDate: nil, maxDate: nil, midDate: nil, limit: 3, personRefresh: nil)
        XCTAssertEqual(messageArray?.count, 3)
        
        
        XCTAssertTrue(deleteMessage(messageId: message2!.id!))
        let messageArray1 = listMessages(conversationId: roomId, sinceDate: nil, maxDate: nil, midDate: nil, limit: 3, personRefresh: nil)
        XCTAssertEqual(messageArray1?.filter({$0.action != MessageAction.tombstone}).count, 2)
        
        XCTAssertTrue(deleteMessage(messageId: message3!.id!))
        let messageArray2 = listMessages(conversationId: roomId, sinceDate: nil, maxDate: nil, midDate: nil, limit: nil, personRefresh: nil)
        XCTAssertEqual(messageArray2?.filter({$0.action == MessageAction.tombstone}).count, 2)
    }
    
    
    private func deleteMessage(messageId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.delete(roomId: self.roomId, messageId: messageId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request) != nil
    }
    
    private func postMessage(conversationId: String, text: String, mentions:[MessageMentionModel]?,files: [FileObjectModel]?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(roomId: conversationId, content: text, mentions: mentions, files: files, queue: nil, uploadProgressHandler: nil, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(conversationId: String, files: [FileObjectModel]?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(roomId: conversationId, content: nil, mentions: nil, files: files, queue: nil, uploadProgressHandler: nil, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personEmail: EmailAddress, text: String, files: [FileObjectModel]?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(email: personEmail.toString(), content: text, mentions: nil, files: files, queue: nil, uploadProgressHandler: nil, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personEmail: EmailAddress, files: [FileObjectModel]) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(email: personEmail.toString(), content: nil, mentions: nil, files: files, queue: nil, uploadProgressHandler: nil, completionHandler: completionHandler)
            
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func flagMessage(messageUrl: String) -> MessageFlagItemModel?{
        let request = { (completionHandler: @escaping (ServiceResponse<MessageFlagItemModel>) -> Void) in
            self.messages.flag(messageUrl: messageUrl, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func listMessages(conversationId: String, sinceDate: String?, maxDate: String?,midDate: String?, limit: Int?,personRefresh: Bool?) -> [Message]? {
        let request = { (completionHandler: @escaping (ServiceResponse<[Message]>) -> Void) in
            self.messages.list(roomId: conversationId,
                               sinceDate: sinceDate,
                               maxDate: maxDate,
                               midDate: midDate,
                               limit: limit,
                               personRefresh:personRefresh,
                               completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func getMessage(messageId: String) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.get(messageID: messageId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func generateLocalFile() -> String?{
        do {
            let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
            UIColor.black.setFill()
            UIRectFill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let cgImage = image?.cgImage else{
                return nil
            }
            let resultImg = UIImage(cgImage: cgImage)
            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
            docURL = docURL?.appendingPathComponent("sample1.png")
            try UIImagePNGRepresentation(resultImg)?.write(to: docURL!)
            return docURL?.absoluteString
        }catch{
            return nil
        }
    }
}


