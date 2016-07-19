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

class TeamSpec: QuickSpec {
    
    private let InvalidId = "abc"
    
    private func validate(team: Team) {
        expect(team.id).notTo(beNil())
        expect(team.name).notTo(beNil())
        expect(team.created).notTo(beNil())
    }
    
    override func spec() {
        beforeSuite {
            Spark.initWith(accessToken: Config.selfUser.token!)
        }
        
        // MARK: - Create a team
        
        describe("create a team") {
            it("normal") {
                do {
                    let teamName = "test team"
                    let team = try Spark.teams.create(name: teamName)
                    
                    self.validate(team)
                    expect(team.name).to(equal(teamName))
                    
                } catch let error as NSError {
                    fail("Failed to create team, \(error.localizedFailureReason)")
                }
            }
        }
        
            it("with empty name") {
                expect{try Spark.teams.create(name: "")}.to(throwError())
            }
            
            it("with special name") {
                do {
                    let teamName = "@@@ &&&"
                    let team = try Spark.teams.create(name: teamName)
                    
                    self.validate(team)
                    expect(team.name).to(equal(teamName))
                    
                } catch let error as NSError {
                    fail("Failed to create team, \(error.localizedFailureReason)")
            }
        }
        
        // MARK: - List a team
    
        describe("list a team") {
            it("normal") {
                do {
                    let team = try Spark.teams.create(name: "test team")
                    let teams = try Spark.teams.list()
                    
                    expect(teams.isEmpty).to(beFalse())
                    expect(teams.contains(){$0 == team}).to(beTrue())
                    
                } catch let error as NSError {
                    fail("Failed to list team, \(error.localizedFailureReason)")
                }
            }
            
            it("with max value") {
                do {
                    let teams = try Spark.teams.list(1)
                    expect(teams.count).to(beLessThanOrEqualTo(1))
                    
                } catch let error as NSError {
                    fail("Failed to list team, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid max") {
                expect{try Spark.teams.list(-1)}.to(throwError())
            }
        }
        
        // MARK: - Get a team
        
        describe("get a team") {
            it("normal") {
                do {
                    let teamName = "test team"
                    let team = try Spark.teams.create(name: teamName)
                    let teamFromGet = try Spark.teams.get(teamId: team.id!)
                    
                    self.validate(teamFromGet)
                    expect(teamFromGet).to(equal(team))
                    
                } catch let error as NSError {
                    fail("Failed to get team, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teams.get(teamId: self.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - Update a team
        
        describe("update a team") {
            it("normal") {
                do {
                    let teamName = "test team"
                    let team = try Spark.teams.create(name: teamName)
                    let newTeamName = "new test team"
                    let teamFromUpdate = try Spark.teams.update(teamId: team.id!, name: newTeamName)
                    
                    self.validate(teamFromUpdate)
                    expect(teamFromUpdate.id).to(equal(team.id))
                    expect(teamFromUpdate.created).to(equal(team.created))
                    expect(teamFromUpdate.name).to(equal(newTeamName))
                    
                } catch let error as NSError {
                    fail("Failed to update team, \(error.localizedFailureReason)")
                }
            }
            
            it("with empty name") {
                do {
                    let team = try Spark.teams.create(name: "test team")
                    let teamFromUpdate = try Spark.teams.update(teamId: team.id!, name: "")
                    
                    self.validate(teamFromUpdate)
                    expect(teamFromUpdate.id).to(equal(team.id))
                    expect(teamFromUpdate.created).to(equal(team.created))
                    expect(teamFromUpdate.name).to(equal(""))
                    
                } catch let error as NSError {
                    fail("Failed to update team, \(error.localizedFailureReason)")
                }
            }
            
            it("with special name") {
                do {
                    let team = try Spark.teams.create(name: "test team")
                    let teamName = "@@@ &&&"
                    let teamFromUpdate = try Spark.teams.update(teamId: team.id!, name: teamName)
                    
                    self.validate(team)
                    expect(teamFromUpdate.name).to(equal(teamName))
                    
                } catch let error as NSError {
                    fail("Failed to create team, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teams.update(teamId: self.InvalidId, name: self.InvalidId)}.to(throwError())
            }
        }
        
        // MARK: - Delete a team
        
        describe("delete a team") {
            it("normal") {
                do {
                    let teamName = "test team"
                    let team = try Spark.teams.create(name: teamName)
                    expect{try Spark.teams.delete(teamId: team.id!)}.notTo(throwError())
                    
                } catch let error as NSError {
                    fail("Failed to delete team, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teams.delete(teamId: self.InvalidId)}.to(throwError())
            }
        }
    }
}