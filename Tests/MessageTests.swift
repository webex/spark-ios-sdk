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
import Quick
import Nimble
@testable import SparkSDK

class MessageSpec: QuickSpec {
    
    private let Text = "test text"
    private let FileUrl = "https://developer.ciscospark.com/index.html"
    private var other: TestUser!
    
    private var room: TestRoom?
    private var roomId: String {
        return room!.id!
    }
    
    private func getISO8601Date() -> String {
        let formatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        formatter.locale = enUSPosixLocale
        formatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX"
        return formatter.string(from: Date())
    }
    
    private func validate(message: Message) {
        expect(message.id).notTo(beNil())
        expect(message.personId).notTo(beNil())
        expect(message.personEmail).notTo(beNil())
        expect(message.roomId).notTo(beNil())
        expect(message.created).notTo(beNil())
    }
    
    override func spec() {
        beforeSuite {
            self.other = TestUserFactory.sharedInstance.createUser()
            Spark.initWith(accessToken: Config.selfUser.token!)
            self.room = TestRoom()
        }
        
        afterSuite {
            Utils.wait(interval: Config.TestcaseInterval)
        }
        
        // MARK: - Post message to room
        
        describe("post message to room") {
            
            it("with text") {
                do {
					let message = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    
                    self.validate(message: message)
                    expect(message.text).to(equal(self.Text))
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with file") {
                do {
                    let message = try Spark.messages.post(roomId: self.roomId, files: self.FileUrl)
                    
                    self.validate(message: message)
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with text/file") {
                do {
                    let message = try Spark.messages.post(roomId: self.roomId, text: self.Text, files: self.FileUrl)
                    
                    self.validate(message: message)
                    expect(message.text).to(equal(self.Text))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                let message = try? Spark.messages.post(roomId: self.roomId)
                expect(message).to(beNil())
            }
            
            it("with invalid room Id") {
                let message = try? Spark.messages.post(roomId: Config.InvalidId, text: self.Text)
                expect(message).to(beNil())
            }
        }
        
        // MARK: - Post message to person with person Id
        
        describe("post message to person with person Id") {
            
            it("with text") {
                do {
                    let message = try Spark.messages.post(personId: (self.other.personId)!, text: self.Text)
                    
                    self.validate(message: message)
                    expect(message.toPersonId).to(equal(self.other.personId))
                    expect(message.text).to(equal(self.Text))
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with file") {
                do {
                    let message = try Spark.messages.post(personId: (self.other.personId)!, files: self.FileUrl)
                    
                    self.validate(message: message)
                    expect(message.toPersonId).to(equal(self.other.personId))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with text/file") {
                do {
                    let message = try Spark.messages.post(personId: (self.other.personId)!, text: self.Text, files: self.FileUrl)
                    
                    self.validate(message: message)
                    expect(message.toPersonId).to(equal(self.other.personId))
                    expect(message.text).to(equal(self.Text))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                let message = try? Spark.messages.post(personId: (self.other.personId)!)
                expect(message).to(beNil())
            }
            
            it("with invalid person Id") {
                let message = try? Spark.messages.post(personId: Config.InvalidId, text: self.Text)
                expect(message).to(beNil())
            }
        }
        
        // MARK: - Post message to person with person email

        describe("post message to person with person email") {
            
            it("with text") {
                do {
                    let message = try Spark.messages.post(personEmail: (self.other.email)!, text: self.Text)
                    
                    self.validate(message: message)
                    expect(message.toPersonEmail).to(equal(self.other.email))
                    expect(message.text).to(equal(self.Text))
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with file") {
                do {
                    let message = try Spark.messages.post(personEmail: (self.other.email)!, files: self.FileUrl)
                    
                    self.validate(message: message)
                    expect(message.toPersonEmail).to(equal(self.other.email))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with text/file") {
                do {
                    let message = try Spark.messages.post(personEmail: (self.other.email)!, text: self.Text, files: self.FileUrl)
                    
                    self.validate(message: message)
                    expect(message.toPersonEmail).to(equal(self.other.email))
                    expect(message.text).to(equal(self.Text))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                let message = try? Spark.messages.post(personEmail: (self.other.email)!)
                expect(message).to(beNil())
            }
            
            it("with invalid person email") {
                let message = try? Spark.messages.post(personEmail: Config.InvalidEmail, text: self.Text)
                expect(message).notTo(beNil())
            }
        }
        
        // MARK: - List message
        
        describe("list message") {
            
            it("normal") {
                do {
                    let messages = try Spark.messages.list(roomId: self.roomId)

                    expect(messages.isEmpty).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to list message, \(error.localizedFailureReason)")
                }
            }
            
            it("with max value") {
                do {
                    let messages = try Spark.messages.list(roomId: self.roomId, max: 2)
                    
                    expect(messages.count).to(equal(2))
                    
                } catch let error as NSError {
                    fail("Failed to list message, \(error.localizedFailureReason)")
                }
            }
            
            it("before a date") {
                do {
                    let message1 = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    Utils.wait(interval: Config.TestcaseInterval)
                    let now = self.getISO8601Date()
                    let message2 = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    
                    let messages = try Spark.messages.list(roomId: self.roomId, before: now)
                    
                    expect(messages.contains() {$0.id == message1.id}).to(beTrue())
                    expect(messages.contains() {$0.id == message2.id}).to(beFalse())

                } catch let error as NSError {
                    fail("Failed to list message, \(error.localizedFailureReason)")
                }
            }
            
            it("before message Id") {
                do {
                    let message1 = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    let message2 = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    
                    let messages = try Spark.messages.list(roomId: self.roomId, beforeMessage: message2.id!)
                    
                    expect(messages.contains() {$0.id == message1.id}).to(beTrue())
                    expect(messages.contains() {$0.id == message2.id}).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to list message, \(error.localizedFailureReason)")
                }
            }
            
            it("before a date and message Id") {
                do {
                    let message = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    let now = self.getISO8601Date()
                    
                    let messages = try Spark.messages.list(roomId: self.roomId, before: now, beforeMessage: message.id!)
                    
                    expect(messages.contains() {$0.id == message.id}).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to list message, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid room Id") {
                expect{try Spark.messages.list(roomId: Config.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - Get message
        
        describe("get message") {
        
            it("normal") {
                do {
                    let messageFromCreate = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    self.validate(message: messageFromCreate)
                    
                    let messageFromGet = try Spark.messages.get(messageId: (messageFromCreate.id)!)
                    self.validate(message: messageFromGet)
                    
                    expect(messageFromGet.id).to(equal(messageFromCreate.id))
                    expect(messageFromGet.text).to(equal(messageFromCreate.text))
                    
                    
                } catch let error as NSError {
                    fail("Failed to get message, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid message Id") {
                expect{try Spark.messages.get(messageId: Config.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - Delete message
        
        describe("delete message") {
        
            it("normal") {
                do {
                    let message = try Spark.messages.post(roomId: self.roomId, text: self.Text)
                    expect{try Spark.messages.delete(messageId: (message.id)!)}.notTo(throwError())
                } catch let error as NSError {
                    fail("Failed to create message, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid message Id") {
                expect{try Spark.messages.delete(messageId: Config.InvalidId)}.to(throwError())
            }
        }
    }
}
