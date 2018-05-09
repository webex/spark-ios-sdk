// Copyright 2016-2018 Cisco Systems Inc
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
        XCTAssertNotNil(message?.roomId)
        XCTAssertNotNil(message?.created)
    }
    
    override func setUp() {
        continueAfterFailure = false
        
        XCTAssertNotNil(fixture)
        if other == nil {
            other = fixture.createUser()
        }
        self.messages = self.fixture.spark.messages
        let room = self.fixture.createRoom(testCase: self, title: "test room")
        XCTAssertNotNil(room?.id)
        self.roomId = room?.id
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
    
    
    func testPostingMessageToPersonWithPersonId() {
        let message = postMessage(personId: other.personId, text: text, files: nil)
        validate(message: message)
        XCTAssertEqual(message?.text, text)
    }
    
    func testPostingMessageToRoomWithTextReturnsMessage() {
        let message = postMessage(conversationId: roomId, text: text, mentions: nil, files:nil)
        validate(message: message)
        XCTAssertEqual(message?.text, text)
    }
    
    func testPostingMessageToRoomWithFileReturnsMessage() {
        let file = LocalFile(path: self.generateLocalFile()!, name: "sample.png", progressHandler: nil)
        let message = postMessage(conversationId: roomId, text: nil, mentions: nil, files: [file!])
        validate(message: message)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageWithTextAndMentionReturnsMessage(){
        let mentionItem = Mention.person(Config.InvalidId)
        let message = postMessage(conversationId: roomId, text: text, mentions:[mentionItem], files: nil)
        validate(message: message)
        XCTAssertEqual(message?.text, text)
    }
    
    func testPostingMessageToRoomWithTextAndFileReturnsMessage() {
        let file = LocalFile(path: self.generateLocalFile()!, name: "sample.png", progressHandler: nil)
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: [file!])
        validate(message: message)
        XCTAssertEqual(message?.text, text)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageToRoomWithTextAndFileAndMentionReturnsMessage(){
        let file = LocalFile(path: self.generateLocalFile()!, name: "sample.png", progressHandler: nil)
        let mentionItem = Mention.person(Config.InvalidId)
        let message = postMessage(conversationId: roomId, text: text, mentions:[mentionItem], files: [file!])
        validate(message: message)
        XCTAssertEqual(message?.text, text)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageToInvalidRoomDoesNotReturnMessage() {
        let message = postMessage(conversationId: Config.InvalidId, text: text, mentions:nil, files: nil)
        XCTAssertNil(message)
    }
    
    func testPostingMessageUsingPersonEmailWithTextReturnsMessage() {
        let message = postMessage(personEmail: other.email, text: text, files: nil)
        validate(message: message)
        XCTAssertEqual(message?.text, text)
    }
    
    func testPostingMessageUsingPersonEmailWithFileReturnsMessage() {
        let file = LocalFile(path: self.generateLocalFile()!, name: "sample.png", progressHandler: nil)
        let message = postMessage(personEmail: other.email, text: "", files: [file!])
        validate(message: message)
        XCTAssertNotNil(message?.files)
    }
    
    func testPostingMessageWithFileAndDwonLoadFile() {
        let file = LocalFile(path: self.generateLocalFile()!)
        let message = postMessage(personEmail: other.email, text: "", files: [file!])
        validate(message: message)
        let expect = expectation(description: "downLoadingFile")
        self.messages.downloadFile((message?.files?.first)!, progressHandler: { (progress) in
            print(progress)
        }) { (response) in
            expect.fulfill()
            let url = response.data
            let image = UIImage(contentsOfFile: (url?.path)!)
            XCTAssertNotNil(image)
        }
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "down load timed out")
        }

    }
    
    func testPostingMessageUsingPersonEmailWithTextAndFileReturnsMessage() {
        let file = LocalFile(path: self.generateLocalFile()!, name: "sample.png", progressHandler: nil)
        let message = postMessage(personEmail: other.email, text: text, files: [file!])
        validate(message: message)
        XCTAssertEqual(message?.text, text)
        XCTAssertNotNil(message?.files)
    }
    
    func testDeleteMessageReturnSuccess(){
        let message = postMessage(personEmail: other.email, text: text, files:nil)
        validate(message: message)
        self.messages.delete(messageId: (message?.id)!){ (response) in
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
        self.messages.get(messageId: (message?.id)!) { (response) in
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
        Thread.sleep(forTimeInterval: 3)
        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: nil, max: nil)
        XCTAssertEqual(messageArray?.isEmpty, false)
    }

    func testListingMessagesWithMaxValueOf2ReturnsOnly2Messages() {
        _ = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        _ = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        _ = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: nil, max: 2)
        XCTAssertEqual(messageArray?.count, 2)
    }
    
    func testListingMessagesBeforeADateReturnsMessagesPostedBeforeThatDate() {
        let message1 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        Thread.sleep(forTimeInterval: 5)
        var nowDate = Date()
        if let createDate = message1?.created,nowDate > createDate.addingTimeInterval(3) {
            nowDate = createDate.addingTimeInterval(3)
        }
        let message2 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: nowDate, max: nil)
        XCTAssertEqual(messageArray?.contains() {$0.id == message1?.id}, true)
        XCTAssertEqual(messageArray?.contains() {$0.id == message2?.id}, false)
    }
    
    func testListingMessagesBeforeADateAndAMessageIdDoesReturnMessageWithThatId() {
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        Thread.sleep(forTimeInterval: 5)
        let now = Date()
        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: now, max: nil)
        XCTAssertEqual(messageArray?.contains() {$0.id == message?.id}, true)
    }

    func testListingMessageWithInvalidRoomIdDoesNotReturnMessage() {
        let messageArray = listMessages(conversationId: Config.InvalidId, mentionedPeople: nil, before: nil, max: nil)
        XCTAssertNil(messageArray)
    }
    
    func testGettingMessageReturnsMessage() {
        let messageFromCreate = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
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
    
    func testDeletingMessageAndItCanNoLongerBeRetrieved() {
        let message = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        validate(message: message)
        XCTAssertTrue(deleteMessage(messageId: (message?.id)!))
        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: nil, max: nil)
        XCTAssertNil(messageArray?.filter({$0.id == message?.id}).first)
    }
    
    func testDeletingMessageWithBadIdFails() {
        XCTAssertFalse(deleteMessage(messageId: Config.InvalidId))
    }
    
    func testSendListDeleteMessage() {
        let message1 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message2 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message3 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        XCTAssertEqual(message1?.text, text)
        XCTAssertEqual(message2?.text, text)
        XCTAssertEqual(message3?.text, text)
        Thread.sleep(forTimeInterval: 3)
        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: nil, max: 3)
        XCTAssertEqual(messageArray?.count, 3)

        XCTAssertTrue(deleteMessage(messageId: message2!.id!))
        let messageArray1 = listMessages(conversationId: roomId, mentionedPeople: nil, before: nil, max: 3)
        XCTAssertEqual(messageArray1?.filter({$0.id == message2?.id}).count, 0)

        XCTAssertTrue(deleteMessage(messageId: message3!.id!))
        let messageArray2 = listMessages(conversationId: roomId, mentionedPeople: nil, before: nil, max: 3)
        XCTAssertEqual(messageArray2?.filter({$0.id == message3?.id}).count, 0)
    }

    func testSendListMessageWithBeforeMessage() {
        let message1 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message2 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message3 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        XCTAssertEqual(message1?.text, text)
        XCTAssertEqual(message2?.text, text)
        XCTAssertEqual(message3?.text, text)

        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: message2?.created, max: 3)
        XCTAssertEqual(messageArray?.filter({$0.id == message3?.id}).count, 0)
    }

    func testSendListMessageWithBefore() {
        let message1 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message2 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message3 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        XCTAssertEqual(message1?.text, text)
        XCTAssertEqual(message2?.text, text)
        XCTAssertEqual(message3?.text, text)

        let messageArray = listMessages(conversationId: roomId, mentionedPeople: nil, before: message2!.created, max: 3)
        XCTAssertEqual(messageArray?.filter({$0.id == message3?.id}).count, 0)
    }

    func testListMessageWithMentionpeople(){
        let message1 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let message2 = postMessage(conversationId: roomId, text: text, mentions:nil, files: nil)
        let mention = Mention.person(other.personId)
        let message3 = postMessage(conversationId: roomId, text: text, mentions:[mention], files: nil)
        XCTAssertEqual(message1?.text, text)
        XCTAssertEqual(message2?.text, text)
        XCTAssertEqual(message3?.text, text)

        let messageArray = listMessages(conversationId: roomId, mentionedPeople: "me" ,before: message2!.created, max: 3)
        XCTAssertEqual(messageArray?.count, 0)
    }
    
    private func deleteMessage(messageId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Any>) -> Void) in
            self.messages.delete(messageId: messageId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request) != nil
    }
    
    private func postMessage(conversationId: String, text: String?, mentions:[Mention]?,files: [LocalFile]?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(roomId: conversationId, text: text, mentions: mentions, files: files, queue: nil, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personEmail: EmailAddress, text: String?, files: [LocalFile]?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(personEmail: personEmail, text: text, files: files, queue: nil, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func postMessage(personId: String, text: String?, files: [LocalFile]?) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.post(personId: personId, text: text, mentions: nil, files: files, queue: nil, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func listMessages(conversationId: String, mentionedPeople: String? ,before: Date?, max: Int?) -> [Message]? {
        let request = { (completionHandler: @escaping (ServiceResponse<[Message]>) -> Void) in
            let beforeDate = before != nil ? Before.date(before!) : nil
            let mentions = mentionedPeople != nil ? Mention.person(mentionedPeople!) : nil
            self.messages.list(roomId: conversationId, before: beforeDate, max: max ?? 50, mentionedPeople: mentions, queue: nil, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func getMessage(messageId: String) -> Message? {
        let request = { (completionHandler: @escaping (ServiceResponse<Message>) -> Void) in
            self.messages.get(messageId: messageId, completionHandler: completionHandler)
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
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/"
            let date : Date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMddyyyyhhmmSSS"
            let todaysDate = dateFormatter.string(from: date)
            let name = "Image-" + todaysDate + ".jpg"
            let destinationPath = path + name
            try UIImageJPEGRepresentation(resultImg, 1.0)?.write(to: URL(fileURLWithPath: destinationPath))
            return destinationPath
        }catch{
            return nil
        }
    }
}


