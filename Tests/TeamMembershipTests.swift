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

class TeamMembershipTests: XCTestCase {
    private var fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private var teamMemberships: TeamMembershipClient!
    private var team: TestTeam?
    private var teamId: String {
        return team!.id!
    }
    
    private func validate(membership: TeamMembership) {
        XCTAssertNotNil(membership.id)
        XCTAssertNotNil(membership.teamId)
        XCTAssertNotNil(membership.personId)
        XCTAssertNotNil(membership.personEmail)
        XCTAssertNotNil(membership.personDisplayName)
        XCTAssertNotNil(membership.created)
        XCTAssertNotNil(membership.isModerator)
    }
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        teamMemberships = fixture.spark.teamMemberships
        team = TestTeam(testCase: self)
    }
    
    func testWhenMembershipIsCreatedWithPersonIdAndNoModeratorStatusThenItCanBeRetrieved() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId),
            let personId = membership.personId,
            let isModerator = membership.isModerator {
            validate(membership: membership)
            XCTAssertEqual(personId, user.personId)
            XCTAssertFalse(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testWhenMembershipIsCreatedWithPersonIdAndTrueModeratorStatusThenItCanBeRetrieved() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId, isModerator: true),
            let personId = membership.personId,
            let isModerator = membership.isModerator {
            validate(membership: membership)
            XCTAssertEqual(personId, user.personId)
            XCTAssertTrue(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testWhenMembershipIsCreatedWithPersonIdAndFalseModeratorStatusThenItCanBeRetrieved() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId, isModerator: false),
            let personId = membership.personId,
            let isModerator = membership.isModerator {
            validate(membership: membership)
            XCTAssertEqual(personId, user.personId)
            XCTAssertFalse(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testWhenMembershipIsCreatedWithPersonEmailAndNoModeratorStatusThenItCanBeRetrieved() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personEmail: user.email),
            let personEmail = membership.personEmail,
            let isModerator = membership.isModerator {
            validate(membership: membership)
            XCTAssertEqual(personEmail, user.email)
            XCTAssertFalse(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testWhenMembershipIsCreatedWithPersonEmailAndTrueModeratorStatusThenItCanBeRetrieved() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personEmail: user.email, isModerator: true),
            let personEmail = membership.personEmail,
            let isModerator = membership.isModerator {
            validate(membership: membership)
            XCTAssertEqual(personEmail, user.email)
            XCTAssertTrue(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testWhenMembershipIsCreatedWithPersonEmailAndFalseModeratorStatusThenItCanBeRetrieved() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personEmail: user.email, isModerator: false),
            let personEmail = membership.personEmail,
            let isModerator = membership.isModerator {
            validate(membership: membership)
            XCTAssertEqual(personEmail, user.email)
            XCTAssertFalse(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testWhenMembershipIsCreatedWithInvalidTeamIdAndPersonIdThenItCannotBeRetrieved() {
        let membership = createMembership(teamId: Config.InvalidId, personId: Config.InvalidId)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testWhenMembershipIsListedThenItContainsCorrectMembers() {
        guard let testTeam = TestTeam(testCase: self) else {
            XCTFail("Failed to create test team")
            return
        }
        
        if let user = fixture.createUser(),
            let testTeamId = testTeam.id,
            let membership1 = createMembership(teamId: testTeamId, personId: user.personId),
            let membership2 = createMembership(teamId: teamId, personId: user.personId),
            let memberships = listMemberships(teamId: testTeamId) {
            validate(membership: membership1)
            validate(membership: membership2)
            XCTAssertTrue(memberships.contains{$0.teamId == testTeamId})
            XCTAssertTrue(memberships.contains{$0.id == membership1.id})
            XCTAssertFalse(memberships.contains{$0.id == membership2.id})
        } else {
            XCTFail("Membership list was incorrect")
        }
    }
    
    func testWhenMembershipIsListedWithMaxValueAndWhenOnlyOneMemberExistsThenListContainsTheCorrectMember() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId),
            let memberships = listMemberships(teamId: teamId, max: 1) {
            validate(membership: membership)
            XCTAssertTrue(memberships.contains{$0.teamId == teamId})
            XCTAssertEqual(memberships.count, 1)
        } else {
            XCTFail("Membership list was incorrect")
        }
    }
    
    func testWhenMembershipIsListedWithInvalidMaxValueAndOneMemberExistsThenListIsNotEmpty() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId),
            let memberships = listMemberships(teamId: teamId, max: -1) {
            validate(membership: membership)
            XCTAssertFalse(memberships.isEmpty)
        } else {
            XCTFail("Membership list was incorrect")
        }
    }
    
    func testWhenTeamIdIsInvalidThenItCannotBeRetrieved() {
        let memberships = listMemberships(teamId: Config.InvalidId)
        XCTAssertNil(memberships, "Unexpected successful request")
    }
    
    func testWhenMembershipIsCreatedItCanBeRetrievedByMembershipId() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId),
            let membershipId = membership.id,
            let membershipFromGet = getMembership(membershipId: membershipId) {
            validate(membership: membership)
            validate(membership: membershipFromGet)
            XCTAssertEqual(membershipFromGet.id, membership.id)
        } else {
            XCTFail("Membership was incorrect")
        }
    }
    
    func testThatMembershipCannotBeRetrievedWithInvalidMembershipId() {
        let membership = getMembership(membershipId: Config.InvalidId)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testWhenUpdatedMembershipCanRemoveModeratorStatus() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId, isModerator: true),
            let id = membership.id,
            let membershipFromUpdate = updateMembership(membershipId: id, isModerator: false),
            let isModerator = membershipFromUpdate.isModerator {
            validate(membership: membership)
            validate(membership: membershipFromUpdate)
            XCTAssertFalse(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testWhenUpdatedMembershipCanBecomeModerator() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId, isModerator: false),
            let id = membership.id,
            let membershipFromUpdate = updateMembership(membershipId: id, isModerator: true),
            let isModerator = membershipFromUpdate.isModerator {
            validate(membership: membership)
            validate(membership: membershipFromUpdate)
            XCTAssertTrue(isModerator)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testThatMembershipCannotBeUpdatedWithInvalidMembershipId() {
        let membership = updateMembership(membershipId: Config.InvalidId, isModerator: false)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testWhenMembershipIsDeletedThenItIsNotPartOfMembershipList() {
        if let user = fixture.createUser(),
            let membership = createMembership(teamId: teamId, personId: user.personId),
            let membershipId = membership.id {
            validate(membership: membership)
            XCTAssertTrue(deleteMembership(membershipId: membershipId))
            let memberships = listMemberships(teamId: teamId)
            XCTAssertNotNil(memberships)
            XCTAssertEqual(memberships?.contains{$0.id == membershipId}, false)
        } else {
            XCTFail("Failed to delete membership")
        }
    }
    
    func testThatMembershipCannotBeDeletedWithInvalidMembershipId() {
        XCTAssertFalse(deleteMembership(membershipId: Config.InvalidId), "Unexpected successful request")
    }
    
    private func createMembership(teamId: String, personId: String, isModerator: Bool = false) -> TeamMembership? {
        let request = { (completionHandler: @escaping (ServiceResponse<TeamMembership>) -> Void) in
            self.teamMemberships.create(teamId: teamId, personId: personId, isModerator: isModerator, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func createMembership(teamId: String, personEmail: EmailAddress, isModerator: Bool = false) -> TeamMembership? {
        let request = { (completionHandler: @escaping (ServiceResponse<TeamMembership>) -> Void) in
            self.teamMemberships.create(teamId: teamId, personEmail: personEmail, isModerator: isModerator, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func listMemberships(teamId: String, max: Int? = nil) -> [TeamMembership]? {
        let request = { (completionHandler: @escaping (ServiceResponse<[TeamMembership]>) -> Void) in
            self.teamMemberships.list(teamId: teamId, max: max, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func getMembership(membershipId: String) -> TeamMembership? {
        let request = { (completionHandler: @escaping (ServiceResponse<TeamMembership>) -> Void) in
            self.teamMemberships.get(membershipId: membershipId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func updateMembership(membershipId: String, isModerator: Bool) -> TeamMembership? {
        let request = { (completionHandler: @escaping (ServiceResponse<TeamMembership>) -> Void) in
            self.teamMemberships.update(membershipId: membershipId, isModerator: isModerator, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func deleteMembership(membershipId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Any>) -> Void) in
            self.teamMemberships.delete(membershipId: membershipId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request) != nil
    }
}
