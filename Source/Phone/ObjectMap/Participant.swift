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
    var enableDTMF: Bool?
    
    init?(_ map: Map){
    }
    
    mutating func mapping(_ map: Map) {
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
        enableDTMF <- map["enableDTMF"]
    }
    
    class ParticipantStateTransform: TransformType {
        typealias Object = ParticipantState
        typealias JSON = String
        
        func transformFromJSON(_ value: Any?) -> Object? {
            guard let state = value as? String else {
                return nil
            }
            return ParticipantState(rawValue: state)
        }

        func transformToJSON(_ value: Object?) -> JSON? {
            guard let state = value else {
                return nil
            }
            return state.rawValue
        }
    }
}
