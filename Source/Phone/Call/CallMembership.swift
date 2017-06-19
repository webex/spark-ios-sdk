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

/// A data type represents a relationship between *Call* and *Person* at Cisco Spark cloud.
///
/// - since: 1.2.0
public struct CallMembership {

    /// The enumeration of the status of the person in the membership.
    ///
    /// - since: 1.2.0
    public enum State : String {
        /// The person status is unknown.
        case unknown
        /// The person is idle w/o any call.
        case idle
        /// The person has been notified about the call.
        case notified
        /// The person has joined the call.
        case joined
        /// The person has left the call.
        case left
        /// The person has declined the call.
        case declined
    }
    
    /// True if the person is the initiator of the call.
    ///
    /// - since: 1.2.0
    public private(set) var isInitiator: Bool
    
    /// The identifier of the person.
    ///
    /// - since: 1.2.0
    public private(set) var presonId: String?

    /// The status of the person in this *CallMembership*.
    ///
    /// - since: 1.2.0
    public var state: State {
        return self.call.model[participant: self.id]?.state ?? .unknown
    }
    
    /// The email address of the person in this *CallMembership*.
    ///
    /// - since: 1.2.0
    public var email: String? {
        return self.call.model[participant: self.id]?.person?.email
    }
    
    /// The SIP address of the person in this *CallMembership*.
    ///
    /// - since: 1.2.0
    public var sipUrl: String? {
        return self.call.model[participant: self.id]?.person?.sipUrl
    }
    
    /// The phone number of the person in this *CallMembership*.
    ///
    /// - since: 1.2.0
    public var phoneNumber: String? {
        return self.call.model[participant: self.id]?.person?.phoneNumber
    }
    
    /// The identifier of the membership.
    ///
    /// - since: 1.2.0
    private let id: String
    
    private let call: Call

    /// Constructs a new *CallMembership*.
    ///
    /// - since: 1.2.0
    init(participant: ParticipantModel, call: Call) {
        self.id = participant.id ?? ""
        self.call = call
        self.isInitiator = participant.isCreator ?? false
        if let personId = participant.person?.id {
            self.presonId = "ciscospark://us/PEOPLE/\(personId)".base64Encoded()
        }
    }
}
