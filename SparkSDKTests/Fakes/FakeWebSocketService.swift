//
//  FakeWebSocketService.swift
//  SparkSDKTests
//
//  Created by panzh on 08/11/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

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
    
    
    override func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if let call = self.callModel {
            self.onCallModel?(call)
        }
    }
    
    func sendOnincomingCall(caller:TestUser,callee:TestUser) {
        self.callModel = FakeCallModelHelper.initCallModel(caller: caller, allParticipantUsers: [caller,callee], selfUser: callee)
        self.websocketDidReceiveMessage(socket: WebSocket(url: URL(fileURLWithPath: Config.FakeWebSocketUrl)), text: "test")
    }
    
}
