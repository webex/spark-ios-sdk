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
import Alamofire
@testable import SparkSDK

class MembershipSpec: QuickSpec {
    
    private let MembershipCountValid = 10
    private var room: TestRoom?
    private var roomId: String {
        return room!.id!
    }
    private var other: TestUser!
    
    private func validate(membership: Membership) {
        expect(membership.id).notTo(beNil())
        expect(membership.personId).notTo(beNil())
        expect(membership.personEmail).notTo(beNil())
        expect(membership.roomId).notTo(beNil())
        expect(membership.isModerator).notTo(beNil())
        expect(membership.isMonitor).notTo(beNil())
        expect(membership.created).notTo(beNil())
    }
    
    override func spec() {
        
        beforeSuite {
            Spark.initWith(accessToken: Config.selfUser.token!)
            self.other = TestUserFactory.sharedInstance.createUser()
            self.room = TestRoom()
        }
        
        afterSuite {
            Utils.wait(interval: Config.TestcaseInterval)
        }
        
        // MARK: - Create a membership by personId
        
        describe("create a membership by personId") {
            
            it("with roomId and personId and flase moderator") {
                do {
                    let membership = try Spark.memberships.create(roomId: self.roomId, personId: self.other.personId!, isModerator: false)
                    self.validate(membership: membership)
                    
                    expect(membership.personId).to(equal(self.other.personId))
                    expect(membership.roomId).to(equal(self.roomId))
                    expect(membership.personEmail).to(equal(self.other.email))
                    expect(membership.isModerator).to(beFalse())
                    expect(membership.isMonitor).to(beFalse())
                    
                    try Spark.memberships.delete(membershipId: (membership.id)!)
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with roomId and personId") {
                do {
                    let membership = try Spark.memberships.create(roomId: self.roomId, personId: self.other.personId!)
                    self.validate(membership: membership)
                    
                    expect(membership.personId).to(equal(self.other.personId!))
                    expect(membership.roomId).to(equal(self.roomId))
                    expect(membership.personEmail).to(equal(self.other.email!))
                    expect(membership.isModerator).to(beFalse())
                    expect(membership.isMonitor).to(beFalse())
                    
                    try Spark.memberships.delete(membershipId: (membership.id)!)
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid roomId and personId") {
                expect{try Spark.memberships.create(roomId: Config.InvalidId, personId: self.other.personId!)}.to(throwError())

            }
            
            it("with roomId and invalid personId") {
                expect{try Spark.memberships.create(roomId: self.roomId, personId: Config.InvalidId)}.to(throwError())
            }
            
            it("with invalid roomId and invalid personId") {
                expect{try Spark.memberships.create(roomId: Config.InvalidId, personId: Config.InvalidId)}.to(throwError())
            }
            
            it("with roomId and personId and true moderator") {
                
                do {
                    let membership = try Spark.memberships.create(roomId: self.roomId, personId: self.other.personId!, isModerator: true)

                    expect(membership.id).notTo(beNil())
                    expect(membership.roomId).to(equal(self.roomId))
                    expect(membership.personEmail).to(equal(self.other.email))
                    expect(membership.isModerator).to(beTrue())
                    
                    do {
                        try Spark.memberships.delete(membershipId: (membership.id)!)
                    } catch let error as NSError {
                        fail("Failed to delete membership, \(error.localizedFailureReason)")
                    }
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
        }
        
        // MARK: - Create a membership by personEmail
        
        describe("create a membership by personEmail") {
            
            it("with roomId and personEmail and flase moderator") {
                
                do {
                    let membership = try Spark.memberships.create(roomId: self.roomId, personEmail: self.other.email!, isModerator: false)
                    self.validate(membership: membership)
                    
                    expect(membership.personId).to(equal(self.other.personId!))
                    expect(membership.roomId).to(equal(self.roomId))
                    expect(membership.personEmail).to(equal(self.other.email!))
                    expect(membership.isModerator).to(beFalse())
                    expect(membership.isMonitor).to(beFalse())
                    
                    try Spark.memberships.delete(membershipId: (membership.id)!)
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with roomId and personEmail") {
                do {
                    let membership = try Spark.memberships.create(roomId: self.roomId, personEmail: self.other.email!)
                    self.validate(membership: membership)
                    
                    expect(membership.personId).to(equal(self.other.personId!))
                    expect(membership.roomId).to(equal(self.roomId))
                    expect(membership.personEmail).to(equal(self.other.email!))
                    expect(membership.isModerator).to(beFalse())
                    expect(membership.isMonitor).to(beFalse())
                    
                    try Spark.memberships.delete(membershipId: (membership.id)!)
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }

            it("with invalid roomId and personEmail") {
                expect{try Spark.memberships.create(roomId: Config.InvalidId, personEmail: self.other.email!)}.to(throwError())
            }
            
            it("with roomId and invalid personEmail") {
                expect{try Spark.memberships.create(roomId: self.roomId, personEmail: Config.InvalidEmail)}.notTo(throwError())
            }
        }
        
        // MARK: - List memberships
        
        describe("list memberships") {
            var membership: Membership?
            
            beforeEach{
                membership = try? Spark.memberships.create(roomId: self.roomId, personId: self.other.personId!, isModerator: false)
            }
            
            afterEach{
                do {
                    try Spark.memberships.delete(membershipId: (membership?.id)!)
                } catch let error as NSError {
                    fail("Failed to delete membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                do {
                    let memberships = try Spark.memberships.list()
                    self.validate(membership: memberships[0])
                    
                }  catch let error as NSError {
                    fail("Failed to list membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with roomId and personId and valid max") {
                do {
                    let memberships = try Spark.memberships.list(roomId: self.roomId, personId: self.other.personId!, personEmail: self.other.email!, max: self.MembershipCountValid)
                    self.validate(membership: memberships[0])
                    
                    expect(memberships[0].personId).to(equal(self.other.personId!))
                    expect(memberships[0].roomId).to(equal(self.roomId))
                    expect(memberships[0].personEmail).to(equal(self.other.email!))
                    expect(memberships[0].isModerator).to(beFalse())
                    expect(memberships[0].isMonitor).to(beFalse())
                    
                }  catch let error as NSError {
                    fail("Failed to list membership, \(error.localizedFailureReason)")
                }
            }
        }
    
        // MARK: - Get membership
        
        describe("get membership") {
            var membership: Membership?
            
            beforeEach{
                membership = try? Spark.memberships.create(roomId: self.roomId, personId: self.other.personId!, isModerator: false)
                if membership == nil {
                    fail("Failed to create membership")
                }
            }
            
            afterEach{
                do {
                    try Spark.memberships.delete(membershipId: (membership?.id)!)
                } catch let error as NSError {
                    fail("Failed to delete membership, \(error.localizedFailureReason)")
                }
            }
            
            it("normal") {
                do {
                    let membershipFromGet = try Spark.memberships.get(membershipId: (membership?.id)!)
                    expect(membershipFromGet == membership!).to(beTrue())
                    
                } catch let error as NSError {
                    fail("Failed to get membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid Id") {
                expect{try Spark.memberships.get(membershipId: Config.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - Update membership
        
        describe("update membership") {
            var membership: Membership?
            
            beforeEach{
                membership = try? Spark.memberships.create(roomId: self.roomId, personId: self.other.personId!, isModerator: false)
                if membership == nil {
                    fail("Failed to create membership")
                }
            }
            
            afterEach{
                do {
                    try Spark.memberships.delete(membershipId: (membership?.id)!)
                } catch let error as NSError {
                    fail("Failed to delete membership, \(error.localizedFailureReason)")
                }
            }
            
            it("normal") {
                do {
                    let membershipFromUpdate = try Spark.memberships.update(membershipId: (membership?.id)!, isModerator: true)
                    expect(membershipFromUpdate.id).to(equal(membership?.id))
                    expect(membershipFromUpdate.isModerator).notTo(equal(membership?.isModerator))
                    
                } catch let error as NSError {
                    fail("Failed to Update membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.memberships.update(membershipId: Config.InvalidId, isModerator: true)}.to(throwError())
            }
        }
        
        // MARK: - Delete membership
        
        describe("delete membership") {
            it("normal") {
                let membership = try? Spark.memberships.create(roomId: self.roomId, personId: self.other.personId!, isModerator: false)
                if membership == nil {
                    fail("Failed to create membership")
                }
                
                expect{try Spark.memberships.delete(membershipId: (membership?.id)!)}.notTo(throwError())
            }
            
            it("with invalid id") {
                expect{try Spark.memberships.delete(membershipId: Config.InvalidId)}.to(throwError())
            }
        }
    }
}
