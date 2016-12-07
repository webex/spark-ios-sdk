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

class TeamSpec: QuickSpec {
    
    private func validate(team: Team) {
        expect(team.id).notTo(beNil())
        expect(team.name).notTo(beNil())
        expect(team.created).notTo(beNil())
    }
    
    override func spec() {
        beforeSuite {
            print("Config.selfUser.token: \(Config.selfUser.token)")
            Spark.initWith(accessToken: Config.selfUser.token!)
        }
        
        // MARK: - Create a team
        
        describe("create a team") {
            it("normal") {
                do {
                    let teamName = "test team"
                    let team = try Spark.teams.create(name: teamName)
                    
                    self.validate(team: team)
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
                    
                    self.validate(team: team)
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
                    let teams = try Spark.teams.list(max: 1)
                    expect(teams.count).to(beLessThanOrEqualTo(1))
                    
                } catch let error as NSError {
                    fail("Failed to list team, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid max") {
				expect{try Spark.teams.list(max: -1)}.to(throwError())
            }
        }
        
        // MARK: - Get a team
        
        describe("get a team") {
            it("normal") {
                do {
                    let teamName = "test team"
                    let team = try Spark.teams.create(name: teamName)
                    let teamFromGet = try Spark.teams.get(teamId: team.id!)
                    
                    self.validate(team: teamFromGet)
                    expect(teamFromGet).to(equal(team))
                    
                } catch let error as NSError {
                    fail("Failed to get team, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teams.get(teamId: Config.InvalidId)}.to(throwError())
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
                    
                    self.validate(team: teamFromUpdate)
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
                    
                    self.validate(team: teamFromUpdate)
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
                    
                    self.validate(team: team)
                    expect(teamFromUpdate.name).to(equal(teamName))
                    
                } catch let error as NSError {
                    fail("Failed to create team, \(error.localizedFailureReason)")
                }
            }
            
            it("with invalid id") {
                expect{try Spark.teams.update(teamId: Config.InvalidId, name: Config.InvalidId)}.to(throwError())
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
                expect{try Spark.teams.delete(teamId: Config.InvalidId)}.to(throwError())
            }
        }
    }
}
