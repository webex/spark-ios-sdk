//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import Starscream
import SwiftyJSON

class WebSocketService: WebSocketDelegate {
    
    static let sharedInstance = WebSocketService()
    
    enum socketError: Int {
        case AuthError = 400
        case Replaced = 4000
    }
    
    let batchingTimeInterval = 0.5
    let reConnectTimeInterval = 1.0
    let connectTimeoutInterval = 60.0
    var reconnectionTimer = NSTimer()
    var batchingTimer = NSTimer()
    var connectionTimer = NSTimer()
    
    private var socket: WebSocket?
    private var webSocketUrl: String?
    private var pendingMessages: [JSON]
    
    init() {
        pendingMessages = [JSON]()
    }
    
    func connect(webSocketUrl: NSURL) {
        createWebSocket(webSocketUrl)
        startConnection()
    }
    
    func disconnect() {
        if socket == nil {
            print("Web socket is nil")
            return
        }
        socket?.disconnect()
    }
    
    private func createWebSocket(webSocketUrl: NSURL) {
        socket = WebSocket(url: webSocketUrl)
        if socket == nil {
            print("Create web socket fail")
            return
        }
        
        socket?.headers["Authorization"] = AuthManager.sharedInstance.authorization()
        socket?.voipEnabled = true
        socket?.selfSignedSSL = true
        socket?.delegate = self
    }
    
    private func startConnection() {
        if socket == nil {
            return
        }
        socket?.connect()
        
        connectionTimer = NSTimer.scheduledTimerWithTimeInterval(connectTimeoutInterval, target: self, selector: #selector(WebSocketService.onConnectTimeout), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(connectionTimer, forMode: NSRunLoopCommonModes)
        batchingTimer = NSTimer.scheduledTimerWithTimeInterval(batchingTimeInterval, target: self, selector: #selector(WebSocketService.onMessagesBatchingTimer), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(batchingTimer, forMode: NSRunLoopCommonModes)
    }
    
    // MARK: - Websocket Delegate Methods.
    
    func websocketDidConnect(socket: WebSocket) {
        print("Websocket is connected")
        cancleConnectionTimer()
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Websocket is disconnected: \(error?.localizedDescription)")
        if (error?.code == socketError.Replaced.rawValue) {
            // The server decided to replace this connection with a different one. Take no action
            return
        }
        if error?.code == socketError.AuthError.rawValue {
            // TODO: handle auth error
        } else {
            print("Websocket will reconnect in \(reConnectTimeInterval) s")
            cancleConnectionTimer()
            cancleBatchingTimer()
            reconnectionTimer = NSTimer.scheduledTimerWithTimeInterval(reConnectTimeInterval, target: self, selector: #selector(WebSocketService.onReconnectionTimer), userInfo: nil, repeats: false)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("Websocket got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        let json = JSON(data: data)
        ackMessage(socket, messageId: json["id"].string!)
        pendingMessages.append(json)
    }
    
    // MARK: - Websocket Event Handler
    
    private func ackMessage(socket: WebSocket, messageId: String) {
        let ack: [String: String] = ["type": "ack", "messageId": messageId]
        do {
            let ackData: NSData = try NSJSONSerialization.dataWithJSONObject(ack, options: NSJSONWritingOptions.PrettyPrinted)
            socket.writeData(ackData)
        } catch {
            
        }
    }
    
    private func processMessages(messages: [JSON]) {
        for message in messages {
            let eventType: String = message["data"]["eventType"].string!
            if eventType.hasPrefix("locus") {
                handleCallEvent(eventType, event: message["data"])
            } else if eventType == "conversation.activity" {
            }
        }
    }
    
    private func handleCallEvent(eventType: String, event: JSON) {
        print("locus event: \(event.object)")
        
        let userInfo: [NSObject: AnyObject] = [Notifications.Locus.NotificationKey: event.object]
        NSNotificationCenter.defaultCenter().postNotificationName(eventType, object: nil, userInfo: userInfo)
    }
    
    // MARK: - Web Socket Timers
    private func cancleConnectionTimer() {
        connectionTimer.invalidate()
        reconnectionTimer.invalidate()
    }
    
    private func cancleBatchingTimer() {
        batchingTimer.invalidate()
    }
    
    @objc private func onConnectTimeout() {
        cancleBatchingTimer()
        startConnection()
    }
    
    @objc private func onMessagesBatchingTimer() {
        let messages = pendingMessages
        
        if messages.count > 0 {
            processMessages(messages)
            pendingMessages.removeObjectsInArray(messages)
        }
    }
    
    @objc private func onReconnectionTimer() {
        startConnection()
    }
}
