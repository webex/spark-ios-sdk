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

import XCTest
@testable import SparkSDK

class RoomTests: XCTestCase {
    
    private let fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private let roomTitle  = "room_for_testing"
    private let specialTitle = "@@@ &&&_%%%"
    private let updatedRoomTitle  = "room_for_testing_updated"
    private var me: TestUser!
    private var rooms: RoomClient!
    private var room: Room?

    private func validate(room: Room?) {
        XCTAssertNotNil(room)
        XCTAssertNotNil(room?.id)
        XCTAssertNotNil(room?.title)
        XCTAssertNotNil(room?.type)
        XCTAssertNotNil(room?.isLocked)
        XCTAssertNotNil(room?.lastActivity)
        XCTAssertNotNil(room?.created)
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        me = fixture.selfUser
        rooms = fixture.spark.rooms
    }
    
    override func tearDown() {
        if let room = room, let roomId = room.id {
            if(!deleteRoom(roomId: roomId)) {
                XCTFail("Failed to delete room")
            }
        }
        Thread.sleep(forTimeInterval: Config.TestcaseInterval)
        super.tearDown()
    }
    
    func testCreatingRoomWithTitleReturnsRoom() {
        room = createRoom(title: roomTitle, teamId: nil)
        validate(room: room)
        XCTAssertEqual(room?.title, roomTitle)
    }
    
    func testCreatingRoomWithEmptyTitleReturnsRoom() {
        room = createRoom(title: "", teamId: nil)
        XCTAssertNotNil(room?.id)
        XCTAssertNil(room?.title)
    }
    
    func testCreatingRoomWithSpecialTitleReturnsRoom() {
        room = createRoom(title: specialTitle, teamId: nil)
        validate(room: room)
        XCTAssertEqual(room?.title, specialTitle)
    }
    
    func testCreatingRoomWithTeamIdReturnsRoom() {
        let team = TestTeam(testCase: self)
        XCTAssertNotNil(team?.id)
        room = createRoom(title: roomTitle, teamId: team?.id)
        validate(room: room)
        XCTAssertEqual(room?.title, roomTitle)
        XCTAssertEqual(room?.teamId, team?.id)
        if(!deleteRoom(roomId: room!.id!)) {
            XCTFail("Failed to delete room")
        }
        room = nil
    }
    
    func testUpdatingRoomWithRoomIdAndTitleReturnsUpdatedRoom() {
        room = createRoom(title: roomTitle, teamId: nil)
        validate(room: room)
        let roomId = (room?.id)!
        let updatedRoom = updateRoom(roomId: roomId, title: updatedRoomTitle)
        validate(room: updatedRoom)
        XCTAssertEqual(updatedRoom?.title, updatedRoomTitle)
    }
    
    func testUpdatingRoomWithInvalidRoomIdFails() {
        room = createRoom(title: roomTitle, teamId: nil)
        let updatedRoom = updateRoom(roomId: Config.InvalidId, title: updatedRoomTitle)
        XCTAssertNil(updatedRoom)
    }
    
    func testUpdatingRoomWithRoomIdAndSpecialTitleReturnsUpdatedRoom() {
        room = createRoom(title: roomTitle, teamId: nil)
        validate(room: room)
        let roomId = (room?.id)!
        let updatedRoom = updateRoom(roomId: roomId, title: specialTitle)
        validate(room: updatedRoom)
        XCTAssertEqual(updatedRoom?.title, specialTitle)
    }
    
    func testDeletingRoomWithRoomIdRemovesRoom() {
        room = createRoom(title: roomTitle, teamId: nil)
        validate(room: room)
        let roomId = (room?.id)!
        XCTAssertTrue(deleteRoom(roomId: roomId))
        XCTAssertNil(getRoom(roomId: roomId))
        room = nil
    }
    
    func testDeletingRoomWithBadIdFails() {
        XCTAssertFalse(deleteRoom(roomId: Config.InvalidId))
    }
    
    func testGettingRoomWithRoomIdReturnsRoom() {
        room = createRoom(title: roomTitle, teamId: nil)
        validate(room: room)
        let roomId = (room?.id)!
        let roomDetails = getRoom(roomId: roomId)
        validate(room: roomDetails)
        XCTAssertEqual(roomDetails?.id, room?.id)
        XCTAssertEqual(roomDetails?.title, room?.title)
    }
    
    func testGettingRoomWithInvalidRoomIdFails() {
        XCTAssertNil(getRoom(roomId: Config.InvalidId))
    }
    
    func testGettingRoomWithEmptyRoomIdReturnsRoom() {
        // XXX: There may be a reason for why we want this behavior, but if so it is not known
        room = createRoom(title: roomTitle, teamId: nil)
        let roomDetails = getRoom(roomId: "")
        XCTAssertNotNil(roomDetails)
        XCTAssertNil(roomDetails?.id)
        XCTAssertNil(roomDetails?.title)
    }
    
    func testListingRoomWithNoDetailsReturnsRoom() {
        room = createRoom(title: roomTitle, teamId: nil)
        let roomArray = listRooms(teamId: nil, max: nil, type: nil)
        if let roomArray = roomArray {
            XCTAssertGreaterThanOrEqual(roomArray.count, 1)
            validate(room: roomArray.first)
        } else {
            XCTFail("Could not retrieve rooms")
        }
    }
    
    func testListingRoomsWithValidMaxReturnsRooms() {
        room = createRoom(title: roomTitle, teamId: nil)
        let roomArray = listRooms(teamId: nil, max: 10, type: nil)
        if let roomArray = roomArray {
            XCTAssertLessThanOrEqual(roomArray.count, 10)
            XCTAssertGreaterThanOrEqual(roomArray.count, 1)
            validate(room: roomArray.first)
        } else {
            XCTFail("Could not retrieve rooms")
        }
    }
    
    func testListingRoomsWithValidMaxAndDirectTypeDoesNotFail() {
        // We do not have a way that we're currently creating "direct" 1-to-1 rooms in this test
        let roomArray = listRooms(teamId: nil, max: 10, type: .direct)
        XCTAssertNotNil(roomArray)
    }
    
    func testListingRoomsWithMaxOf1ReturnsOnly1Room() {
        room = createRoom(title: roomTitle, teamId: nil)
        let otherRoom = createRoom(title: roomTitle, teamId: nil)
        let roomArray = listRooms(teamId: nil, max: 1, type: nil)
        if let roomArray = roomArray {
            XCTAssertEqual(roomArray.count, 1)
            validate(room: roomArray.first)
        } else {
            XCTFail("Could not retrieve rooms")
        }
        _ = deleteRoom(roomId: (otherRoom?.id)!)
    }
    
    func testListingRoomsWithInvalidMaxFails() {
        XCTAssertNil(listRooms(teamId: nil, max: -1, type: nil))
    }
    
    func testListingRoomWithTeamIdReturnsRoom() {
        let team = TestTeam(testCase: self)
        XCTAssertNotNil(team?.id)
        room = createRoom(title: roomTitle, teamId: team?.id)
        validate(room: room)
        XCTAssertNotNil(room?.teamId)
        if let roomArray = listRooms(teamId: team?.id, max: nil, type: nil) {
            XCTAssertEqual(roomArray.first?.id, room?.id)
            XCTAssertEqual(roomArray.first?.teamId, room?.teamId)
            if(!deleteRoom(roomId: room!.id!)) {
                XCTFail("Failed to delete room")
            }
            room = nil
        } else {
            XCTFail("Could not retrieve rooms")
        }
    }
    
    private func createRoom(title: String, teamId: String?) -> Room? {
        let request = { (completionHandler: @escaping (ServiceResponse<Room>) -> Void) in
            self.rooms.create(title: title, teamId: teamId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func updateRoom(roomId: String, title: String) -> Room? {
        let request = { (completionHandler: @escaping (ServiceResponse<Room>) -> Void) in
            self.rooms.update(roomId: roomId, title: title, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func getRoom(roomId: String) -> Room? {
        let request = { (completionHandler: @escaping (ServiceResponse<Room>) -> Void) in
            self.rooms.get(roomId: roomId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func listRooms(teamId: String?, max: Int?, type: RoomType?) -> [Room]? {
        let request = { (completionHandler: @escaping (ServiceResponse<[Room]>) -> Void) in
            self.rooms.list(teamId: teamId, max: max, type: type, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func deleteRoom(roomId: String) -> Bool {
        let request = { (completionHandler: @escaping (ServiceResponse<Any>) -> Void) in
            self.rooms.delete(roomId: roomId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request) != nil
    }
}
