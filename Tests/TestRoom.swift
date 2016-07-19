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
import SparkSDK

class TestRoom {
    var room: Room?
    var id: String? {
        return room?.id
    }
    var title: String? {
        return room?.title
    }
    
    init?() {
        do {
            room = try Spark.rooms.create(title: "room_for_test")
            
        } catch let error as NSError {
            fail("Failed to create room, \(error.localizedFailureReason)")
            
            return nil
        }
    }
    
    deinit {
        guard id != nil else {
            return
        }
        do {
            try Spark.rooms.delete(roomId: id!)
        } catch let error as NSError {
            fail("Failed to delete room, \(error.localizedFailureReason)")
        }
    }
}