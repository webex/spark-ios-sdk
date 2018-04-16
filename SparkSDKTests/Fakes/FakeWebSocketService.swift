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
@testable import SparkSDK
import Starscream
import SwiftyJSON
import ObjectMapper

class FakeWebSocketService:WebSocketService {
    private var callModel:CallModel?
    
    override func connect(_ webSocketUrl: URL, _ block: @escaping (Error?) -> Void) {
        block(nil)
    }
    
    
    override func disconnect() {
        
    }
    
    override func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        if let call = self.callModel {
            self.onCallModel?(call)
        }
    }
    
    func sendOnincomingCall(caller:TestUser,callee:TestUser) {
        self.callModel = FakeCallModelHelper.initCallModel(caller: caller, allParticipantUsers: [caller,callee], selfUser: callee)
        if let call = self.callModel {
            self.onCallModel?(call)
        }
    }
    
    
}

