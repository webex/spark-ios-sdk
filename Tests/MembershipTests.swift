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
import XCTest
@testable import SparkSDK

class MembershipTests: XCTestCase {
    
    private var fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private let MembershipCountValid = 10
    private var memberships: MembershipClient!
    private var room: TestRoom?
    private var roomId: String! {
        if let room = room, let roomId = room.id {
            return roomId
        } else {
            XCTFail("Missing required information about room")
            return nil
        }
    }
    private var other: TestUser!
    private var membership: Membership?
    
    private func validate(membership: Membership) {
        XCTAssertNotNil(membership.id)
        XCTAssertNotNil(membership.personId)
        XCTAssertNotNil(membership.personEmail)
        XCTAssertNotNil(membership.roomId)
        XCTAssertNotNil(membership.isModerator)
        XCTAssertNotNil(membership.isMonitor)
        XCTAssertNotNil(membership.created)
    }
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        if other == nil {
            other = fixture.createUser()
        }
        memberships = fixture.spark.memberships
        room = TestRoom()
    }
    
    override func tearDown() {
        if let membership = membership, let membershipId = membership.id {
            if(!deleteMembership(membershipId: membershipId)) {
                XCTFail("Failed to delete membership")
            }
        }
        super.tearDown()
    }
    
    override static func tearDown() {
        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
        super.tearDown()
    }
    
    func testCreateNonModeratorMembershipWithRoomIdAndPersonId() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        if let membership = membership {
            XCTAssertEqual(membership.roomId, roomId)
            XCTAssertEqual(membership.personEmail, other.email)
            XCTAssertEqual(membership.personId, other.personId)
            XCTAssertEqual(membership.isModerator, false)
            XCTAssertEqual(membership.isMonitor, false)
            validate(membership: membership)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testCreateMembershipWithInvalidRoomIdButValidPersonId() {
        membership = createMembership(roomId: Config.InvalidId, personId: other.personId, isModerator: false)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testCreateMembershipWithValidRoomIdButInvalidPersonId() {
        membership = createMembership(roomId: roomId, personId: Config.InvalidId, isModerator: false)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testCreateMembershipWithInvalidRoomIdAndInvalidPersonId() {
        membership = createMembership(roomId: Config.InvalidId, personId: Config.InvalidId, isModerator: false)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testCreateModeratorMembershipWithRoomIdAndPersonId() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: true)
        if let membership = membership {
            XCTAssertEqual(membership.roomId, roomId)
            XCTAssertEqual(membership.personEmail, other.email)
            XCTAssertEqual(membership.isModerator, true)
            validate(membership: membership)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testCreateNonModeratorMembershipWithRoomIdAndPersonEmail() {
        membership = createMembership(roomId: roomId, personEmail: other.email, isModerator: false)
        if let membership = membership {
            XCTAssertEqual(membership.personId, other.personId)
            XCTAssertEqual(membership.roomId, roomId)
            XCTAssertEqual(membership.personEmail, other.email)
            XCTAssertEqual(membership.isModerator, false)
            XCTAssertEqual(membership.isMonitor, false)
            validate(membership: membership)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testCreateMembershipWithInvalidRoomIdButValidEmail() {
        membership = createMembership(roomId: Config.InvalidId, personEmail: other.email, isModerator: false)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testCreateMembershipWithValidRoomIdButInvalidEmail() {
        membership = createMembership(roomId: roomId, personEmail: Config.InvalidEmail, isModerator: false)
        XCTAssertNil(membership, "Unexpected successful request")
    }
    
    func testCreateModeratorMembershipWithRoomIdAndPersonEmail() {
        membership = createMembership(roomId: roomId, personEmail: other.email, isModerator: true)
        if let membership = membership {
            XCTAssertEqual(membership.personId, other.personId)
            XCTAssertEqual(membership.roomId, roomId)
            XCTAssertEqual(membership.personEmail, other.email)
            XCTAssertEqual(membership.isModerator, true)
            validate(membership: membership)
        } else {
            XCTFail("Failed to create membership")
        }
    }
    
    func testListingMembershipWithNoFiltersFindsMembership() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        if let list = listMemberships(roomId: nil, personId: nil, max: nil) {
            var foundMembership: Membership? = nil
            for currentMembership in list {
                if currentMembership.personId == other.personId && currentMembership.roomId == roomId {
                    validate(membership: currentMembership)
                    foundMembership = currentMembership
                }
            }
            XCTAssertNotNil(foundMembership)
        } else {
            XCTFail("No memberships returned")
        }
    }
    
    func testListingMembershipWithRoomIdAndPersonIdAndMaxCountFindsMembership() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        if let list = listMemberships(roomId: roomId, personId: other.personId, max: 10) {
            XCTAssertEqual(list.count, 1)
            let foundMembership = list[0]
            XCTAssertEqual(foundMembership.personId, other.personId)
            XCTAssertEqual(foundMembership.personEmail, other.email)
            XCTAssertEqual(foundMembership.roomId, roomId)
            XCTAssertEqual(foundMembership.isModerator, false)
            XCTAssertEqual(foundMembership.isMonitor, false)
            validate(membership: foundMembership)
        } else {
            XCTFail("No memberships returned")
        }
    }
    
    func testListingMembershipWithOnlyRoomIdFindsMembership() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        if let list = listMemberships(roomId: roomId, personId: nil, max: nil) {
            var foundMembership: Membership? = nil
            for currentMembership in list {
                if currentMembership.personId == other.personId {
                    validate(membership: currentMembership)
                    foundMembership = currentMembership
                }
            }
            XCTAssertNotNil(foundMembership)
        } else {
            XCTFail("No memberships returned")
        }
    }
    
    func testListingMembershipWithOnlyPersonIdFindsMembership() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        if let list = listMemberships(roomId: nil, personId: other.personId, max: nil) {
            XCTAssertEqual(list.count, 1)
            let foundMembership = list[0]
            XCTAssertEqual(foundMembership.personId, other.personId)
            XCTAssertEqual(foundMembership.personEmail, other.email)
            XCTAssertEqual(foundMembership.roomId, roomId)
            validate(membership: foundMembership)
        } else {
            XCTFail("No memberships returned")
        }
    }
    
    func testGettingMembershipReturnsMembership() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        if let membershipId = membership?.id, let foundMembership = getMembership(membershipId: membershipId) {
            XCTAssertEqual(foundMembership, membership)
        } else {
            XCTFail("Failed to get membership")
        }
    }
    
    func testGettingMembershipWithInvalidIdDoesNotReturnMembership() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        let foundMembership = getMembership(membershipId: Config.InvalidId)
        XCTAssertNil(foundMembership)
    }
    
    func testUpdatingMembershipToAddModeratorReturnsMembershipWithModerator() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        if let membershipId = membership?.id, let updatedMembership = updateMembership(membershipId: membershipId, isModerator: true) {
            XCTAssertEqual(updatedMembership.id, membershipId)
            XCTAssertEqual(updatedMembership.isModerator, true)
        } else {
            XCTFail("Failed to update membership")
        }
    }
    
    func testDeletingMembershipRemovesMembershipAndItCanNoLongerBeRetrieved() {
        let membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        XCTAssertNotNil(membership?.id)
        let membershipId = (membership?.id)!
        XCTAssertTrue(deleteMembership(membershipId: membershipId))
        XCTAssertNil(getMembership(membershipId: membershipId))
    }
    
    func testDeletingMembershipWithBadIdFails() {
        XCTAssertFalse(deleteMembership(membershipId: Config.InvalidId))
    }
    
    func testUpdatingMembershipWithInvalidIdDoesNotReturnMembership() {
        membership = createMembership(roomId: roomId, personId: other.personId, isModerator: false)
        let updatedMembership = updateMembership(membershipId: Config.InvalidId, isModerator: true)
        XCTAssertNil(updatedMembership)
    }
    
    private func createMembership(roomId: String, personEmail: EmailAddress, isModerator: Bool) -> Membership? {
        let request = { (completionHandler: @escaping (ServiceResponse<Membership>) -> Void) in
            self.memberships.create(roomId: roomId, personEmail: personEmail, isModerator: isModerator, completionHandler: completionHandler)
        }
        return Utils.getResponse(testCase: self, request: request)
    }
    
    private func createMembership(roomId: String, personId: String, isModerator: Bool) -> Membership? {
        let request = { (completionHandler: @escaping (ServiceResponse<Membership>) -> Void) in
            self.memberships.create(roomId: roomId, personId: personId, isModerator: isModerator, completionHandler: completionHandler)
        }
        return Utils.getResponse(testCase: self, request: request)
    }
    
    private func deleteMembership(membershipId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Any>) -> Void) in
            self.memberships.delete(membershipId: membershipId, completionHandler: completionHandler)
        }
        return Utils.getResponse(testCase: self, request: request) != nil
    }
    
    private func listMemberships(roomId: String?, personId: String?, max: Int?) -> [Membership]? {
        let request = { (completionHandler: @escaping (ServiceResponse<[Membership]>) -> Void) in
            self.memberships.list(roomId: roomId, personId: personId, max: max, completionHandler: completionHandler)
        }
        return Utils.getResponse(testCase: self, request: request)
    }
    
    private func getMembership(membershipId: String) -> Membership? {
        let request = { (completionHandler: @escaping (ServiceResponse<Membership>) -> Void) in
            self.memberships.get(membershipId: membershipId, completionHandler: completionHandler)
        }
        return Utils.getResponse(testCase: self, request: request)
    }
    
    private func updateMembership(membershipId: String, isModerator: Bool) -> Membership? {
        let request = { (completionHandler: @escaping (ServiceResponse<Membership>) -> Void) in
            self.memberships.update(membershipId: membershipId, isModerator: isModerator, completionHandler: completionHandler)
        }
        return Utils.getResponse(testCase: self, request: request)
    }
}
