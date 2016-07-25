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

class TeamMembershipSpec: QuickSpec {
    
    private var team: TestTeam?
    private var teamId: String {
        return team!.id!
    }
    
    private func validate(membership: TeamMembership) {
        expect(membership.id).notTo(beNil())
        expect(membership.teamId).notTo(beNil())
        expect(membership.personId).notTo(beNil())
        expect(membership.personEmail).notTo(beNil())
        expect(membership.personDisplayName).notTo(beNil())
        expect(membership.created).notTo(beNil())
        expect(membership.isModerator).notTo(beNil())
    }
    
    override func spec() {
        beforeSuite {
            Spark.initWith(accessToken: Config.selfUser.token!)
            self.team = TestTeam()
        }
        
        // MARK: - Create a membership
        
        describe("create a membership") {
            it("by person Id") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!)
                    
                    self.validate(membership)
                    expect(membership.personId).to(equal(user.personId))
                    expect(membership.isModerator).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("by person Id with isModerator true") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!, isModerator: true)
                    
                    self.validate(membership)
                    expect(membership.personId).to(equal(user.personId))
                    expect(membership.isModerator).to(beTrue())
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("by person Id with isModerator false") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!, isModerator: false)
                    
                    self.validate(membership)
                    expect(membership.personId).to(equal(user.personId))
                    expect(membership.isModerator).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("by person email") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personEmail: user.email!)
                    
                    self.validate(membership)
                    expect(membership.personEmail).to(equal(user.email))
                    expect(membership.isModerator).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("by person email with isModerator true") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personEmail: user.email!, isModerator: true)
                    
                    self.validate(membership)
                    expect(membership.personEmail).to(equal(user.email))
                    expect(membership.isModerator).to(beTrue())
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("by person email with isModerator false") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personEmail: user.email!)
                    
                    self.validate(membership)
                    expect(membership.personEmail).to(equal(user.email))
                    expect(membership.isModerator).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to create membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teamMemberships.create(teamId: Config.InvalidId, personId: Config.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - List a membership
        
        describe("list a membership") {
            it("normal") {
                do {
                    guard let testTeam = TestTeam() else {
                        fail("Failed to create test team")
                        return
                    }
                    
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership1 = try Spark.teamMemberships.create(teamId: testTeam.id!, personId: user.personId!)
                    self.validate(membership1)
                    
                    let membership2 = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!)
                    self.validate(membership2)
                    
                    let memberships = try Spark.teamMemberships.list(teamId: testTeam.id!)
                    expect(memberships.contains{$0.teamId == testTeam.id}).to(beTrue())
                    expect(memberships.contains{$0 == membership1}).to(beTrue())
                    expect(memberships.contains{$0 == membership2}).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to list membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with max value") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!)
                    self.validate(membership)
                    
                    let memberships = try Spark.teamMemberships.list(teamId: self.teamId, max: 1)
                    expect(memberships.contains{$0.teamId == self.teamId}).to(beTrue())
                    expect(memberships.count).to(equal(1))
                    
                } catch let error as NSError {
                    fail("Failed to list membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid max value") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!)
                    self.validate(membership)
                    
                    let memberships = try Spark.teamMemberships.list(teamId: self.teamId, max: -1)
                    expect(memberships.isEmpty).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to list membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teamMemberships.list(teamId: Config.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - Get a membership
        
        describe("get a membership") {
            it("normal") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!)
                    self.validate(membership)
                    
                    let membershipFromGet = try Spark.teamMemberships.get(membershipId: membership.id!)
                    self.validate(membershipFromGet)
                    expect(membershipFromGet).to(equal(membership))
                    
                } catch let error as NSError {
                    fail("Failed to get membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
               expect{try Spark.teamMemberships.get(membershipId: Config.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - Update a membership
        
        describe("update a membership") {
            it("make isModerator true") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!, isModerator: false)
                    self.validate(membership)
                    
                    let membershipFromUpdate = try Spark.teamMemberships.update(membershipId: membership.id!, isModerator: true)
                    self.validate(membershipFromUpdate)
                    expect(membershipFromUpdate.isModerator).to(beTrue())
                    
                } catch let error as NSError {
                    fail("Failed to update membership, \(error.localizedFailureReason)")
                }
            }
            
            it("make isModerator false") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!, isModerator: true)
                    self.validate(membership)
                    
                    let membershipFromUpdate = try Spark.teamMemberships.update(membershipId: membership.id!, isModerator: false)
                    self.validate(membershipFromUpdate)
                    expect(membershipFromUpdate.isModerator).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to update membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teamMemberships.update(membershipId: Config.InvalidId, isModerator: false)}.to(throwError())
            }
        }
        
         // MARK: - Delete a membership
        
        describe("delete a membership") {
            it("normal") {
                do {
                    let user = TestUserFactory.sharedInstance.createUser()
                    let membership = try Spark.teamMemberships.create(teamId: self.teamId, personId: user.personId!)
                    self.validate(membership)
                    
                    expect{try Spark.teamMemberships.delete(membershipId: membership.id!)}.notTo(throwError())
                    
                    let memberships = try Spark.teamMemberships.list(teamId: self.teamId)
                    expect(memberships).notTo(beNil())
                    expect(memberships.contains{$0 == membership}).to(beFalse())
                    
                } catch let error as NSError {
                    fail("Failed to delete membership, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teamMemberships.delete(membershipId: Config.InvalidId)}.to(throwError())
            }
        }
    }
}