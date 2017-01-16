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

import Quick
import Nimble
import Alamofire
@testable import SparkSDK

class RoomSpec: QuickSpec {
    
    private let RoomTitle  = "room_for_testing"
    private let SpecialTitle = "@@@ &&&_%%%"
    private let UpdatedRoomTitle  = "room_for_testing_updated"
    private let RoomCountMin = 1
    private let RoomCountMax = 100    //TO BE DETERMINED
    private let RoomCountValid = 10
    private let RoomCountInvalid = -1
    private var me = Config.selfUser
    
    private func validate(room: Room) {
        expect(room.id).notTo(beNil())
        expect(room.title).notTo(beNil())
        expect(room.type).notTo(beNil())
        expect(room.isLocked).notTo(beNil())
        expect(room.lastActivity).notTo(beNil())
        expect(room.created).notTo(beNil())
    }
    
    override func spec() {
        
        beforeSuite {
            Spark.initWith(accessToken: self.me.token!)
        }
        
        // MARK: - Create a Room
        
        describe("create a room") {
            
            afterEach {
                Utils.wait(interval: Config.TestcaseInterval)
            }
            
            it("sync with title") {
                do {
                    let room = try Spark.rooms.create(title: self.RoomTitle)
                    self.validate(room: room)
                    
                    expect(room.title).to(equal(self.RoomTitle))
                    
                } catch let error as NSError {
                    fail("Failed to create room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with emptyTitle") {
                do {
                    let room = try Spark.rooms.create(title: "")

                    expect(room.id).notTo(beNil())
                    expect(room.title).to(beNil())

                } catch let error as NSError {
                    fail("Failed to create room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with specialTitle") {
                do {
                    let room = try Spark.rooms.create(title: self.SpecialTitle)
                    self.validate(room: room)
                    
                    expect(room.title).to(equal(self.SpecialTitle))
                    
                } catch let error as NSError {
                    fail("Failed to create room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with teamId") {
                do {
                    let team = TestTeam()
                    let room = try Spark.rooms.create(title: self.RoomTitle, teamId: team?.id)
                    expect(room.title).to(equal(self.RoomTitle))
                    expect(room.teamId).to(equal(team?.id))
                    
                } catch let error as NSError {
                    fail("Failed to create team, \(error.localizedFailureReason)")
                }
            }
        }
        
        // MARK: - Update a Room
        
        describe("update a room") {
            
            var room: TestRoom? = nil
            
            beforeEach {
                room = TestRoom()
                if room != nil {
                    self.validate(room: room!.room!)
                }
            }
            
            afterEach {
                Utils.wait(interval: Config.TestcaseInterval)
            }
            
            it("sync with roomId and title") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let updatedRoom = try Spark.rooms.update(roomId: room!.id!, title: self.UpdatedRoomTitle)
                    self.validate(room: updatedRoom)
                    expect(updatedRoom.id).notTo(beNil())
                    expect(updatedRoom.title).to(equal(self.UpdatedRoomTitle))
                    
                }  catch let error as NSError {
                    fail("Failed to update team, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with invalid roomId") {
                expect{try Spark.rooms.update(roomId: Config.InvalidId, title: self.UpdatedRoomTitle)}.to(throwError())
            }
            
            it("sync with roomId and specialTitle") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let updatedRoom = try Spark.rooms.update(roomId: room!.id!, title: self.SpecialTitle)
                    expect(updatedRoom.title).to(equal(self.SpecialTitle))
                    
                }  catch let error as NSError {
                    fail("Failed to update team, \(error.localizedFailureReason)")
                }
            }
        }
        
        // MARK: - Delete a Room
        
        describe("delete a room") {
            
            var room: Room? = nil
            
            beforeEach {
                do {
                    room = try Spark.rooms.create(title: self.RoomTitle)
                    self.validate(room: room!)
                    
                } catch let error as NSError {
                    fail("Failed to create team, \(error.localizedFailureReason)")
                }
                
                Utils.wait(interval: Config.TestcaseInterval)
            }
            
            it("sync with roomId") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    try Spark.rooms.delete(roomId: room!.id!)
                } catch let error as NSError {
                    fail("Failed to delete room, \(error.localizedFailureReason)")
                }
                
                expect{try Spark.rooms.get(roomId: room!.id!)}.to(throwError())
            }
            
            it("sync with invalid RoomId") {
                expect{try Spark.rooms.delete(roomId: Config.InvalidId)}.to(throwError())
            }
            
            it("sync with empty RoomId") {
                expect{try Spark.rooms.delete(roomId: "")}.to(throwError())
            }
        }
        
        // MARK: - Get a room
        
        describe("get a room") {
            
            var room: TestRoom? = nil
            
            beforeEach {
                room = TestRoom()
                if room != nil {
                    self.validate(room: room!.room!)
                }
            }
            
            afterEach {
                Utils.wait(interval: Config.TestcaseInterval)
            }
            
            it("sync with roomId") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let roomDetails = try Spark.rooms.get(roomId: room!.id!)
                    self.validate(room: roomDetails)
                    expect(roomDetails.id!).to(equal(room?.id!))
                    expect(roomDetails.title!).to(equal(room?.title!))
                    
                } catch let error as NSError {
                    fail("Failed to get room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with invalid roomId") {
                expect{try Spark.rooms.get(roomId: Config.InvalidId)}.to(throwError())
            }
            
            it("sync with emptyRoomId") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let roomDetails = try Spark.rooms.get(roomId: "")
                    
                    expect(roomDetails).notTo(beNil())
                    expect(roomDetails.id).to(beNil())
                    expect(roomDetails.title).to(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to get room, \(error.localizedFailureReason)")
                }
            }
        }
        
        // MARK: - List rooms
        
        describe("list rooms") {
            
            var room: TestRoom? = nil
            
            beforeEach {
                room = TestRoom()
                if room != nil {
                    self.validate(room: room!.room!)
                }
            }
            
            afterEach {
                Utils.wait(interval: Config.TestcaseInterval)
            }
            
            it("sync with nothing") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let rooms = try Spark.rooms.list()
                    expect(rooms.count).to(beGreaterThanOrEqualTo(self.RoomCountMin))
                    expect(rooms[0].id).notTo(beNil())
                    expect(rooms[0].title).notTo(beNil())
                    
                } catch let error as NSError {
                    fail("Failed to list room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with valid max") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let rooms = try Spark.rooms.list(max: self.RoomCountValid)
                    expect(rooms.count).to(beLessThanOrEqualTo(self.RoomCountValid))
                    expect(rooms.count).to(beGreaterThanOrEqualTo(self.RoomCountMin))
                    self.validate(room: rooms[0])
                    
                } catch let error as NSError {
                    fail("Failed to list room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with valid max and direct type") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let rooms = try Spark.rooms.list(max: self.RoomCountValid, type: .direct)
                    expect(rooms.count).to(beGreaterThanOrEqualTo(0))
                    
                } catch let error as NSError {
                    fail("Failed to get room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with min max") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let rooms = try Spark.rooms.list(max: self.RoomCountMin)
                    expect(rooms.count).to(equal(self.RoomCountMin))
                    self.validate(room: rooms[0])
                    
                } catch let error as NSError {
                    fail("Failed to get room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with min max and direct group") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let rooms = try Spark.rooms.list(max: self.RoomCountMin, type: .direct)
                    expect(rooms.count).to(beGreaterThanOrEqualTo(0))
                    
                } catch let error as NSError {
                    fail("Failed to get room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with max max") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let rooms = try Spark.rooms.list(max: self.RoomCountMax)
                    expect(rooms.count).to(beLessThanOrEqualTo(self.RoomCountMax))
                    expect(rooms.count).to(beGreaterThanOrEqualTo(self.RoomCountMin))
                    self.validate(room: rooms[0])
                    
                } catch let error as NSError {
                    fail("Failed to get room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with max max and direct type") {
                guard room?.id != nil else {
                    return
                }
                
                do {
                    let rooms = try Spark.rooms.list(max: self.RoomCountMax, type: .direct)
                    expect(rooms.count).to(beGreaterThanOrEqualTo(0))
                    
                } catch let error as NSError {
                    fail("Failed to get room, \(error.localizedFailureReason)")
                }
            }
            
            it("sync with invalid max") {
                expect{try Spark.rooms.list(max: self.RoomCountInvalid)}.to(throwError())
            }
            
            it("sync with invalid max and direct type") {
                expect{try Spark.rooms.list(max: self.RoomCountInvalid, type: .direct)}.to(throwError())
            }
            
            it("sync with teamId") {
                do {
                    let team = TestTeam()
                    let room = try Spark.rooms.create(title: self.RoomTitle, teamId: team?.id)
                    expect(room).notTo(beNil())
                    
                    let rooms = try Spark.rooms.list(teamId: team?.id)
                    expect(rooms.contains{$0.id == room.id}).to(beTrue())
                    expect(rooms.contains{$0.teamId == room.teamId}).to(beTrue())
                    
                } catch let error as NSError {
                    fail("Failed to list team, \(error.localizedFailureReason)")
                }
            }
        }
    }
}
