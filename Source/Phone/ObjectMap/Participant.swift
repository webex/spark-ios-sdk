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
import ObjectMapper

struct Participant: Mappable {
    var isCreator: Bool?
    var id: String?
    var url: String?
    var state: ParticipantState?
    var type: String?
    var person: ParticipantInfo?
    var devices: [ParticipantDevice]?
    var status: ParticipantStatus?
    var deviceUrl: String?
    var mediaBaseUrl: String?
    var guest: Bool?
    var alertHint: AlertHint?
    var alertType: AlertType?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(map: Map) {
        isCreator <- map["isCreator"]
        id <- map["id"]
        url <- map["url"]
        state <- (map["state"], ParticipantStateTransform())
        type <- map["type"]
        person <- map["person"]
        devices <- map["devices"]
        status <- map["status"]
        deviceUrl <- map["deviceUrl"]
        mediaBaseUrl <- map["mediaBaseUrl"]
        guest <- map["guest"]
        alertHint <- map["alertHint"]
        alertType <- map["alertType"]
    }
    
    class ParticipantStateTransform: TransformType {
        typealias Object = ParticipantState
        typealias JSON = String
        
        func transformFromJSON(value: AnyObject?) -> Object? {
            guard let state = value as? String else {
                return nil
            }
            return ParticipantState(rawValue: state)
        }

        func transformToJSON(value: Object?) -> JSON? {
            guard let state = value else {
                return nil
            }
            return state.rawValue
        }
    }
}
