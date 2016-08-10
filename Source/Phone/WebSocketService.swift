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
import Starscream
import SwiftyJSON

class WebSocketService: WebSocketDelegate {
    
    static let sharedInstance = WebSocketService()
    
    private var socket: WebSocket?
    private let MessageBatchingIntervalInSec = 0.5
    private let ConnectionTimeoutIntervalInSec = 60.0
    private var connectionTimeoutTimer: NSTimer?
    private var messageBatchingTimer: NSTimer?
    private var connectionRetryCounter: ExponentialBackOffCounter
    private var pendingMessages: [JSON]
    
    init() {
        connectionRetryCounter = ExponentialBackOffCounter(minimum: 0.5, maximum: 32, multiplier: 2)
        pendingMessages = [JSON]()
    }
    
    deinit {
        cancelConnectionTimeOutTimer()
        cancelMessageBatchingTimer()
    }
    
    func connect(webSocketUrl: NSURL) {
        if socket == nil {
            socket = createWebSocket(webSocketUrl)
            guard socket != nil else {
                Logger.error("Skip connection due to failure of creating socket")
                return
            }
        }
        
        if socket!.isConnected {
            Logger.warn("Web socket is already connected")
            return
        }
        
        Logger.info("Web socket is being connected")
        
        socket?.connect()
        
        scheduleConnectionTimeoutTimer()
    }
    
    func disconnect() {
        guard socket != nil else {
            Logger.warn("Web socket has not been connected")
            return
        }
        
        guard socket!.isConnected else {
            Logger.warn("Web socket is already disconnected")
            return
        }
        
        Logger.info("Web socket is being disconnected")
        
        socket?.disconnect()
        socket = nil
    }
    
    private func reconnect() {
        guard socket != nil else {
            Logger.warn("Web socket has not been connected")
            return
        }
        
        guard !socket!.isConnected else {
            Logger.warn("Web socket has already connected")
            return
        }
        
        Logger.info("Web socket is being reconnected")
        
        socket?.connect()
    }
    
    private func createWebSocket(webSocketUrl: NSURL) -> WebSocket? {
        // Need to check authorization, avoid crash when logout as soon as login
        guard let authorization = AuthManager.sharedInstance.getAuthorization() else {
            Logger.error("Failed to create web socket due to no authorization")
            return nil
        }
        
        socket = WebSocket(url: webSocketUrl)
        if socket == nil {
            Logger.error("Failed to create web socket")
            return nil
        }
        
        socket?.headers.unionInPlace(authorization)
        socket?.voipEnabled = true
        socket?.selfSignedSSL = true
        socket?.delegate = self
        
        return socket
    }
    
    private func despatch_main_after(delay: Double, closure: () -> Void) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    // MARK: - Websocket Delegate Methods.
    
    func websocketDidConnect(socket: WebSocket) {
        Logger.info("Websocket is connected")
    
        connectionRetryCounter.reset()
        scheduleMessageBatchingTimer()
        cancelConnectionTimeOutTimer()
        
        ReachabilityService.sharedInstance.fetch()
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        cancelMessageBatchingTimer()
        cancelConnectionTimeOutTimer()
        
        guard let code = error?.code, discription = error?.localizedDescription else {
            return
        }
        Logger.info("Websocket is disconnected: \(code), \(discription)")
        
        guard self.socket != nil else {
            Logger.info("Websocket is disconnected on purpose")
            return
        }
        
        let backoffTime = connectionRetryCounter.next()
        if code > Int(WebSocket.CloseCode.Normal.rawValue) {
            // Abnormal disconnection, re-register device.
            self.socket = nil
            Logger.error("Abnormal disconnection, re-register device in \(backoffTime) seconds")
            despatch_main_after(backoffTime) {
                Spark.phone.register(nil)
            }
        } else {
            // Unexpected disconnection, reconnect socket.
            Logger.warn("Unexpected disconnection, websocket will reconnect in \(backoffTime) seconds")
            despatch_main_after(backoffTime) {
                self.reconnect()
            }
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        Logger.info("Websocket got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        let json = JSON(data: data)
        ackMessage(socket, messageId: json["id"].string!)
        pendingMessages.append(json)
    }
    
    // MARK: - Websocket Event Handler
    
    private func ackMessage(socket: WebSocket, messageId: String) {
        let ack = JSON(["type": "ack", "messageId": messageId])
        do {
            let ackData: NSData = try ack.rawData(options: .PrettyPrinted)
            socket.writeData(ackData)
        } catch {
            Logger.error("Failed to acknowledge message")
        }
    }
    
    private func processMessages() {
        for message in pendingMessages {
            let eventData = message["data"]
            if let eventType = eventData["eventType"].string {
                if eventType.hasPrefix("locus") {
                    Logger.info("locus event: \(eventData.object)")
                    CallManager.sharedInstance.handleCallEvent(eventData.object)
                }
            }
        }
        
        pendingMessages.removeAll()
    }
    
    // MARK: - Web Socket Timers
    
    private func scheduledTimerWithTimeInterval(timeInterval: NSTimeInterval, selector: Selector, repeats: Bool) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: selector, userInfo: nil, repeats: repeats)
    }
    
    private func scheduleMessageBatchingTimer() {
        messageBatchingTimer = scheduledTimerWithTimeInterval(MessageBatchingIntervalInSec, selector: #selector(onMessagesBatchingTimerFired), repeats: true)
    }
    
    private func cancelMessageBatchingTimer() {
        messageBatchingTimer?.invalidate()
        messageBatchingTimer = nil
    }
    
    private func scheduleConnectionTimeoutTimer() {
        connectionTimeoutTimer = scheduledTimerWithTimeInterval(ConnectionTimeoutIntervalInSec, selector: #selector(onConnectionTimeOutTimerFired), repeats: false)
    }
    
    private func cancelConnectionTimeOutTimer() {
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = nil
    }

    @objc private func onMessagesBatchingTimerFired() {
        processMessages()
    }
    
    @objc private func onConnectionTimeOutTimerFired() {
        Logger.info("Connect timed out, try to reconnect")
        reconnect()
    }
}
