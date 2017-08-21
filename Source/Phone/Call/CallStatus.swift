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

/// The status of a *Call*. 
///
/// The following diagram shows all statuses and transitions triggered 
/// by either an API call or an event received by the Spark iOS SDK.
/// The <span style="color:orange">orange</span> transtions are triggered by API calls.
/// The <span style="color:blue">blue</span> transitions are triggered by events.
/// Illegal API calls during certain statuses will result callbacks with *Error* without transitions.
///
/// ![Status Diagram](https://raw.githubusercontent.com/ciscospark/spark-ios-sdk/Release/1.2.0/Misc/phone_status_diagram.png)
///
/// - since: 1.2.0
public enum CallStatus {
    /// For the outgoing call, the call has dialed.
    /// For the incoming call, the call has received.
    case initiated
    /// For the outgoing call, the call is ringing the remote party.
    /// For the incoming call, the call is ringing the local party.
    case ringing
    /// The call is answered.
    case connected
    /// The call is terminated.
    case disconnected
    
    func handle(model: CallModel, for call: Call) {
        guard let local = model.myself else {
            return;
        }
        switch self {
        case .initiated, .ringing:
            if call.direction == Call.Direction.incoming {
                if call.isRemoteJoined {
                    if local.isJoined(by: call.device.deviceUrl) {
                        call.status = .connected
                        DispatchQueue.main.async {
                            call.onConnected?()
                        }
                    }
                    else if local.isDeclined(by: call.device.deviceUrl) {
                        call.end(reason: Call.DisconnectReason.localDecline)
                    }
                    else if local.isJoined {
                        call.end(reason: Call.DisconnectReason.otherConnected)
                    }
                    else if local.isDeclined {
                        call.end(reason: Call.DisconnectReason.otherDeclined)
                    }
                }
                else if call.isRemoteDeclined || call.isRemoteLeft {
                    call.end(reason: Call.DisconnectReason.remoteCancel)
                }
            }
            else {
                if local.isLeft {
                    call.end(reason: Call.DisconnectReason.localCancel)
                }
                else if local.isJoined(by: call.device.deviceUrl) {
                    if call.isGroup {
                        call.status = .ringing
                        DispatchQueue.main.async {
                            call.onRinging?()
                            call.status = .connected
                            DispatchQueue.main.async {
                                call.onConnected?()
                            }
                        }
                    }
                    else {
                        if call.isRemoteNotified {
                            call.status = .ringing
                            DispatchQueue.main.async {
                                call.onRinging?()
                            }
                        }
                        else if call.isRemoteJoined {
                            call.status = .connected
                            DispatchQueue.main.async {
                                call.onConnected?()
                            }
                        }
                        else if call.isRemoteDeclined {
                            call.end(reason: Call.DisconnectReason.remoteDecline)
                        }
                    }
                }
            }
        case .connected:
            if call.isGroup {
                if local.isLeft {
                    call.end(reason: Call.DisconnectReason.localLeft)
                }
            }
            else {
                if local.isLeft {
                    call.end(reason: Call.DisconnectReason.localLeft)
                }
                else if call.isRemoteLeft {
                    call.end(reason: Call.DisconnectReason.remoteLeft)
                }
            }
        case .disconnected:
            break;
        }
    }
}

extension Call {
   
    var isRemoteLeft: Bool {
        if self.isGroup {
            return false
        }
        for membership in self.memberships {
            if !membership.isSelf && membership.state != CallMembership.State.left {
                return false
            }
        }
        return true
    }
    
    var isRemoteJoined: Bool {
        if self.isGroup {
            return true
        }
        for membership in self.memberships {
            if !membership.isSelf && membership.state != CallMembership.State.joined {
                return false
            }
        }
        return true
    }
    
    var isRemoteDeclined: Bool {
        if self.isGroup {
            return false
        }
        for membership in self.memberships {
            if !membership.isSelf && membership.state != CallMembership.State.declined {
                return false
            }
        }
        return true
    }
    
    var isRemoteNotified: Bool {
        if self.isGroup {
            return true
        }
        for membership in self.memberships {
            if !membership.isSelf && (membership.state == CallMembership.State.idle || membership.state == CallMembership.State.notified) {
                return true
            }
        }
        return false
    }
}


