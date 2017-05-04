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

public enum CallStatus {
    case initiated
    case ringing
    case connected
    case disconnected
    
    func handle(model: CallModel, for call: Call) {
        guard let local = model.myself else {
            return;
        }
        switch self {
        case .initiated:
            if call.direction == Call.Direction.incoming {
                if model.isRemoteJoined {
                    if local.isJoined(by: call.device.deviceUrl) {
                        call.status = .connected
                        DispatchQueue.main.async {
                            call.onConnected?()
                        }
                    }
                    else if local.isDeclined(by: call.device.deviceUrl) {
                        call.device.phone.remove(call: call)
                        call.status = .disconnected
                        DispatchQueue.main.async {
                            call.onDisconnected?(Call.DisconnectType.localDecline)
                        }
                    }
                    else if local.isJoined {
                        call.device.phone.remove(call: call)
                        call.status = .disconnected
                        DispatchQueue.main.async {
                            call.onDisconnected?(Call.DisconnectType.otherConnected)
                        }
                    }
                    else if local.isDeclined {
                        call.device.phone.remove(call: call)
                        call.status = .disconnected
                        DispatchQueue.main.async {
                            call.onDisconnected?(Call.DisconnectType.otherDeclined)
                        }
                    }
                }
                else if model.isRemoteDeclined {
                    call.device.phone.remove(call: call)
                    call.status = .disconnected
                    DispatchQueue.main.async {
                        call.onDisconnected?(Call.DisconnectType.remoteCancel)
                    }
                }
            }
            else if local.isJoined(by: call.device.deviceUrl) && model.isRemoteNotified {
                call.status = .ringing
                DispatchQueue.main.async {
                    call.onRinging?()
                }
            }
        case .ringing:
            if local.isLeft {
                call.device.phone.remove(call: call)
                call.status = .disconnected
                DispatchQueue.main.async {
                    call.onDisconnected?(Call.DisconnectType.localCancel)
                }
            }
            else if model.isRemoteJoined {
                call.status = .connected
                DispatchQueue.main.async {
                    call.onConnected?()
                }
            }
            else if model.isRemoteDeclined {
                call.device.phone.remove(call: call)
                call.status = .disconnected
                DispatchQueue.main.async {
                    call.onDisconnected?(Call.DisconnectType.remoteDecline)
                }
            }
        case .connected:
            if local.isLeft {
                call.device.phone.remove(call: call)
                call.status = .disconnected
                DispatchQueue.main.async {
                    call.onDisconnected?(Call.DisconnectType.localLeft)
                }
            }
            else if model.isRemoteLeft {
                call.device.phone.remove(call: call)
                call.status = .disconnected
                DispatchQueue.main.async {
                    call.onDisconnected?(Call.DisconnectType.remoteLeft)
                }
            }
        case .disconnected:
            break;
        }
    }
}
