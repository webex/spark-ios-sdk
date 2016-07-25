// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
        let formatter = NSDateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.locale = enUSPosixLocale
        formatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX"
        return formatter.stringFromDate(NSDate())
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
            Utils.wait(Config.TestcaseInterval)
        }
        
        // MARK: - Post message to room
        
        describe("post message to room") {
            
            it("with text") {
                do {
                    let message = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
                    
                    self.validate(message)
                    expect(message.text).to(equal(self.Text))
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with file") {
                do {
                    let message = try Spark.messages.postToRoom(roomId: self.roomId, files: self.FileUrl)
                    
                    self.validate(message)
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with text/file") {
                do {
                    let message = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text, files: self.FileUrl)
                    
                    self.validate(message)
                    expect(message.text).to(equal(self.Text))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                let message = try? Spark.messages.postToRoom(roomId: self.roomId)
                expect(message).to(beNil())
            }
            
            it("with invalid room Id") {
                let message = try? Spark.messages.postToRoom(roomId: Config.InvalidId, text: self.Text)
                expect(message).to(beNil())
            }
        }
        
        // MARK: - Post message to person with person Id
        
        describe("post message to person with person Id") {
            
            it("with text") {
                do {
                    let message = try Spark.messages.postToPerson(personId: (self.other.personId)!, text: self.Text)
                    
                    self.validate(message)
                    expect(message.toPersonId).to(equal(self.other.personId))
                    expect(message.text).to(equal(self.Text))
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with file") {
                do {
                    let message = try Spark.messages.postToPerson(personId: (self.other.personId)!, files: self.FileUrl)
                    
                    self.validate(message)
                    expect(message.toPersonId).to(equal(self.other.personId))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with text/file") {
                do {
                    let message = try Spark.messages.postToPerson(personId: (self.other.personId)!, text: self.Text, files: self.FileUrl)
                    
                    self.validate(message)
                    expect(message.toPersonId).to(equal(self.other.personId))
                    expect(message.text).to(equal(self.Text))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                let message = try? Spark.messages.postToPerson(personId: (self.other.personId)!)
                expect(message).to(beNil())
            }
            
            it("with invalid person Id") {
                let message = try? Spark.messages.postToPerson(personId: Config.InvalidId, text: self.Text)
                expect(message).to(beNil())
            }
        }
        
        // MARK: - Post message to person with person email

        describe("post message to person with person email") {
            
            it("with text") {
                do {
                    let message = try Spark.messages.postToPerson(personEmail: (self.other.email)!, text: self.Text)
                    
                    self.validate(message)
                    expect(message.toPersonEmail).to(equal(self.other.email))
                    expect(message.text).to(equal(self.Text))
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with file") {
                do {
                    let message = try Spark.messages.postToPerson(personEmail: (self.other.email)!, files: self.FileUrl)
                    
                    self.validate(message)
                    expect(message.toPersonEmail).to(equal(self.other.email))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with text/file") {
                do {
                    let message = try Spark.messages.postToPerson(personEmail: (self.other.email)!, text: self.Text, files: self.FileUrl)
                    
                    self.validate(message)
                    expect(message.toPersonEmail).to(equal(self.other.email))
                    expect(message.text).to(equal(self.Text))
                    expect(message.files).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to post message, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                let message = try? Spark.messages.postToPerson(personEmail: (self.other.email)!)
                expect(message).to(beNil())
            }
            
            it("with invalid person email") {
                let message = try? Spark.messages.postToPerson(personEmail: Config.InvalidEmail, text: self.Text)
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
                    let message1 = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
                    Utils.wait(Config.TestcaseInterval)
                    let now = self.getISO8601Date()
                    let message2 = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
                    
                    let messages = try Spark.messages.list(roomId: self.roomId, before: now)
                    
                    expect(messages.contains() {$0.id == message1.id}).to(beTrue())
                    expect(messages.contains() {$0.id == message2.id}).to(beFalse())

                } catch let error as NSError {
                    fail("Failed to list message, \(error.localizedFailureReason)")
                }
            }
            
            it("before message Id") {
                do {
                    let message1 = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
                    let message2 = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
                    
                    let messages = try Spark.messages.list(roomId: self.roomId, beforeMessage: message2.id!)
                    
                    expect(messages.contains() {$0.id == message1.id}).to(beTrue())
                    expect(messages.contains() {$0.id == message2.id}).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to list message, \(error.localizedFailureReason)")
                }
            }
            
            it("before a date and message Id") {
                do {
                    let message = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
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
                    let messageFromCreate = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
                    self.validate(messageFromCreate)
                    
                    let messageFromGet = try Spark.messages.get(messageId: (messageFromCreate.id)!)
                    self.validate(messageFromGet)
                    
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
                    let message = try Spark.messages.postToRoom(roomId: self.roomId, text: self.Text)
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