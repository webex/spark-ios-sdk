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

public struct CallMembership {

    public enum State : String {
        case unknown
        case idle
        case notified
        case joined
        case left
        case declined
    }
    
    public let id: String
    
    public let isInitiator: Bool
    
    public let presonId: String?

    public var state: State {
        return self.call.model[participant: self.id]?.state ?? .unknown
    }
    
    public var email: String? {
        return self.call.model[participant: self.id]?.person?.email
    }
    
    public var sipUrl: String? {
        return self.call.model[participant: self.id]?.person?.sipUrl
    }
    
    public var phoneNumber: String? {
        return self.call.model[participant: self.id]?.person?.phoneNumber
    }
        
    private let call: Call
    
    init(participant: ParticipantModel, call: Call) {
        self.id = participant.id ?? ""
        self.call = call
        self.isInitiator = participant.isCreator ?? false
        self.presonId = participant.person?.id
    }
}
