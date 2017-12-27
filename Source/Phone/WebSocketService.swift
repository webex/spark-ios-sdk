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
import Starscream
import SwiftyJSON
import ObjectMapper

class WebSocketService: WebSocketDelegate {
    
    var onCallModel: ((CallModel) -> Void)?
    var onFailed: (() -> Void)?
    var onActivityModel: ((ActivityModel) -> Void)?
    var onKmsMessageModel: ((KmsMessageModel) -> Void)?
    
    private var socket: WebSocket?
    private var connectionRetryCounter: ExponentialBackOffCounter
    private let queue = DispatchQueue(label: "com.cisco.spark-ios-sdk.WSQueue-\(UUID().uuidString)")
    private let authenticator: Authenticator
    
    private var onConnected: ((Error?) -> Void)?
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
        self.connectionRetryCounter = ExponentialBackOffCounter(minimum: 0.5, maximum: 32, multiplier: 2)
    }
    
    func connect(_ webSocketUrl: URL, _ block: @escaping (Error?) -> Void) {
        self.queue.async {
            if let socket = self.socket, socket.isConnected {
                SDKLogger.shared.warn("Web socket has already connected")
                block(nil)
                return
            }
            self.socket = nil
            self.authenticator.accessToken { token in
                self.queue.async {
                    SDKLogger.shared.info("Web socket is being connected")
                    let socket = WebSocket(url: webSocketUrl)
                    if let token = token {
                        socket.headers["Authorization"] = "Bearer " + token
                    }
                    socket.callbackQueue = self.queue
                    socket.delegate = self
                    self.onConnected = block
                    self.socket = socket
                    socket.connect()
                }
            }
        }
    }
    

    func disconnect() {
        self.queue.async {
            if let socket = self.socket, socket.isConnected {
                SDKLogger.shared.info("Web socket is being disconnected")
                socket.disconnect()
                self.socket = nil
                return
            }
            self.socket = nil
        }
    }
    
    // MARK: - Websocket Delegate Methods.
    func websocketDidConnect(socket: WebSocket) {
        SDKLogger.shared.info("Websocket is connected")
        if let block = self.onConnected {
            block(nil)
            self.onConnected = nil
        }
        self.connectionRetryCounter.reset()
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let block = self.onConnected {
            SDKLogger.shared.info("Websocket cannot connect: \(String(describing: error))")
            let code = error?.code ?? -7000
            let reason = error?.localizedDescription ?? "Websocket cannot connect"
            block(SparkError.serviceFailed(code: code, reason: reason))
            self.onConnected = nil
        }
        else if let code = error?.code, let desc = error?.localizedDescription {
            SDKLogger.shared.info("Websocket is disconnected: \(code), \(desc)")
            if self.socket == nil {
                SDKLogger.shared.info("Websocket is disconnected on purpose")
            }
            else {
                let backoffTime = connectionRetryCounter.next()
                despatch_after(backoffTime) {
                    if code > Int(WebSocket.CloseCode.normal.rawValue) {
                        // Abnormal disconnection, re-register device.
                        SDKLogger.shared.error("Abnormal disconnection, re-register device in \(backoffTime) seconds")
                        self.socket = nil
                        self.onFailed?()
                    } else {
                        // Unexpected disconnection, reconnect socket.
                        SDKLogger.shared.warn("Unexpected disconnection, websocket will reconnect in \(backoffTime) seconds")
                        if let socket = self.socket, !socket.isConnected {
                            SDKLogger.shared.info("Web socket is being reconnected")
                            socket.connect()
                        }
                    }
                }
            }
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        SDKLogger.shared.info("Websocket got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        let json = JSON(data: data)
        ackMessage(socket, messageId: json["id"].string ?? "")
        let eventData = json["data"]
        if let eventType = eventData["eventType"].string {
            if eventType.hasPrefix("locus") {
                let eventObj = eventData.object;
                guard let eventJson = eventObj as? [String: Any],
                    let event = Mapper<CallEventModel>().map(JSON: eventJson),
                    let call = event.callModel,
                    let type = event.type else {
                        SDKLogger.shared.error("Malformed call event could not be processed as a call event \(eventObj)")
                        return
                }
                SDKLogger.shared.info("Receive locus event: \(type)")
                self.onCallModel?(call)
            }else if(eventType == "conversation.activity"){
                let activityObj = eventData["activity"].object;
                guard let eventJson = activityObj as? [String: Any],
                    var activityModel = Mapper<ActivityModel>().map(JSON: eventJson)
                    else {
                        return
                }
                activityModel.eventType = eventType
                self.onActivityModel?(activityModel)
            }else if(eventType == "status.start_typing" || eventType == "status.stop_typing" || eventType == "user.app_item"){
                let activityObj = eventData.object;
                guard let eventJson = activityObj as? [String: Any],
                    let activityModel = Mapper<ActivityModel>().map(JSON: eventJson)
                    else {
                        return
                }
                self.onActivityModel?(activityModel)
            }else if(eventType == "encryption.kms_message"){
                 let kmsMessageObj = eventData["encryption"].object
                guard let kmsMessageJson = kmsMessageObj as? [String: Any],
                    let kmsMessageModel = Mapper<KmsMessageModel>().map(JSON: kmsMessageJson)
                    else{
                        return;
                }
                self.onKmsMessageModel?(kmsMessageModel)
            }
        }
    }
    
    // MARK: - Websocket Event Handler
    private func ackMessage(_ socket: WebSocket, messageId: String) {
        let ack = JSON(["type": "ack", "messageId": messageId])
        do {
            let ackData: Data = try ack.rawData(options: .prettyPrinted)
            socket.write(data: ackData)
        } catch {
            SDKLogger.shared.error("Failed to acknowledge message")
        }
    }
    
    private func despatch_after(_ delay: Double, closure: @escaping () -> Void) {
        self.queue.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
}
