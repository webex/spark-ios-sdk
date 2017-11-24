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

class XCTeamSpec: XCTestCase {
    
    private let fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private var teams: TeamClient!
    private var team: Team?
    private func validate(team: Team?) {
        XCTAssertNotNil(team, "Failed request")
        XCTAssertNotNil(team?.id)
        XCTAssertNotNil(team?.name)
        XCTAssertNotNil(team?.created)
    }
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        teams = fixture.spark.teams
    }
    
    override func tearDown() {
        if let createTeamId = self.team?.id {
            fixture.deleteTeam(testCase: self, teamId: createTeamId)
        }
    }
    
    func testBasicCreateTeam() {
        let teamName = "test team"
        self.team = fixture.createTeam(testCase: self, teamName: teamName)
        validate(team: self.team)
        XCTAssertEqual(self.team?.name, teamName)
    }
    
    func testCreateTeamWithNoNameFails() {
        self.team = fixture.createTeam(testCase: self, teamName: "")
        XCTAssertNil(self.team, "Unexpected successful request")
    }
    
    func testCreateTeamWithSpecialCharacters() {
        let teamName = "@@@ &&&"
        self.team = fixture.createTeam(testCase: self, teamName: teamName)
        validate(team: self.team)
        XCTAssertEqual(self.team?.name, teamName)
    }
    
    func testBasicListTeams() {
        self.team = fixture.createTeam(testCase: self, teamName: "test team")
        let teams = listTeams()
        if let teams = teams {
            XCTAssertGreaterThan(teams.count, 0)
            XCTAssert(teams.contains() { $0.id == team?.id })
        } else {
            XCTFail("Failed to list team")
        }
    }
    
    func testListTeamsWithMax() {
        if let teams = listTeams(max: 1) {
            XCTAssertLessThanOrEqual(teams.count, 1)
        } else {
            XCTFail("Failed to list team")
        }
    }
    
    func testListTeamsWithInvalidMaxFails() {
        let teams = listTeams(max: -1)
        if let teamsList = teams {
          XCTAssertEqual(teamsList.count, 0)
        }
        else {
            XCTAssertNil(teams, "Unexpected successful request")
        }
    }
    
    func testBasicGetTeam() {
        let teamCreated = fixture.createTeam(testCase: self, teamName: "test team")
        XCTAssertNotNil(teamCreated)
        self.team = teamCreated
        if let teamId = teamCreated!.id, let teamFromGet = getTeam(teamId: teamId) {
            self.validate(team: teamFromGet)
            XCTAssertEqual(teamFromGet.id, teamCreated!.id)
        } else {
            XCTFail("Failed to get team")
        }
    }
    
    func testGetATeamWithInvalidIdFails() {
        let team = getTeam(teamId: Config.InvalidId)
        XCTAssertNil(team, "Unexpected successful request")
    }
    
    func testBasicUpdateTeam() {
        let updatedName = "new test team"
        let teamCreated = fixture.createTeam(testCase: self, teamName: "test team")
        XCTAssertNotNil(teamCreated)
        self.team = teamCreated
        if  let teamId = teamCreated!.id, let teamFromUpdate = updateTeam(teamId: teamId, name: updatedName) {
            self.validate(team: teamFromUpdate)
            XCTAssertEqual(teamFromUpdate.id, teamCreated!.id)
            XCTAssertEqual(teamFromUpdate.created, teamCreated!.created)
            XCTAssertEqual(teamFromUpdate.name, updatedName)
        } else {
            XCTFail("Failed to update team")
        }
    }
    
    func testUpdateTeamWithEmptyName() {
        let updatedName = ""
        let teamCreated = fixture.createTeam(testCase: self, teamName: "test team")
        XCTAssertNotNil(teamCreated)
        self.team = teamCreated
        if  let teamId = teamCreated!.id, let teamFromUpdate = updateTeam(teamId: teamId, name: updatedName) {
            self.validate(team: teamFromUpdate)
            XCTAssertEqual(teamFromUpdate.id, teamCreated!.id)
            XCTAssertEqual(teamFromUpdate.created, teamCreated!.created)
            XCTAssertEqual(teamFromUpdate.name, updatedName)
        } else {
            XCTFail("Failed to update team")
        }
    }
    
    func testUpdateTeamWithSpecialName() {
        let updatedName = "@@@ &&&"
        let teamCreated = fixture.createTeam(testCase: self, teamName: "test team")
        XCTAssertNotNil(teamCreated)
        self.team = teamCreated
        if let teamId = teamCreated!.id, let teamFromUpdate = updateTeam(teamId: teamId, name: updatedName) {
            self.validate(team: teamFromUpdate)
            XCTAssertEqual(teamFromUpdate.id, teamCreated!.id)
            XCTAssertEqual(teamFromUpdate.created, teamCreated!.created)
            XCTAssertEqual(teamFromUpdate.name, updatedName)
        } else {
            XCTFail("Failed to update team")
        }
    }
    
    func testUpdateTeamWithInvalidIdFails() {
        let team = updateTeam(teamId: Config.InvalidId, name: Config.InvalidId)
        XCTAssertNil(team, "Unexpected successful request")
    }
    
    func testBasicDeleteTeam() {
        if let teamCreated = fixture.createTeam(testCase: self, teamName: "test team"), let teamId = teamCreated.id {
            XCTAssertTrue(fixture.deleteTeam(testCase: self, teamId: teamId))
        } else {
            XCTFail("Failed to create team")
        }
    }
    
    func testDeleteTeamWithInvalidIdFails() {
        XCTAssertFalse(fixture.deleteTeam(testCase: self, teamId: Config.InvalidId), "Unexpected successful request")
    }

    func testCreateUpdateListAndDeleteIt() {
        let teamCreated = fixture.createTeam(testCase: self, teamName: "test team")
        XCTAssertNotNil(teamCreated)
        XCTAssertNotNil(teamCreated?.id)
        let team = getTeam(teamId: (teamCreated!.id)!)
        XCTAssertEqual(team?.name, teamCreated?.name)
        
        let newName = "test team1"
        let teamUpdate = updateTeam(teamId: teamCreated!.id!, name: newName)
        XCTAssertNotNil(teamUpdate)
        XCTAssertEqual(teamUpdate?.name, newName)
        
        let team1 = getTeam(teamId: teamCreated!.id!)
        XCTAssertNotNil(team1)
        XCTAssertEqual(team1?.name, newName)
        
        XCTAssertTrue(fixture.deleteTeam(testCase: self, teamId: teamCreated!.id!))
        
        
    }
    
    private func listTeams(max: Int? = nil) -> [Team]? {
        let request = { (completionHandler: @escaping (ServiceResponse<Array<Team>>) -> Void) in
            self.teams.list(max: max, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func getTeam(teamId: String) -> Team? {
        let request = { (completionHandler: @escaping (ServiceResponse<Team>) -> Void) in
            self.teams.get(teamId: teamId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func updateTeam(teamId: String, name: String) -> Team? {
        let request = { (completionHandler: @escaping (ServiceResponse<Team>) -> Void) in
            self.teams.update(teamId: teamId, name: name, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
}
