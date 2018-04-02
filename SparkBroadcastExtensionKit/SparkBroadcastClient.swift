//
//  SparkBroadcastClient.swift
//  SparkBroadcastExtensionKit
//
//  Created by panzh on 17/03/2018.
//  Copyright © 2018 Cisco. All rights reserved.
//

import Foundation
import SparkSDKBroadcastUtil
class SparkBroadcastClient : BroadcastConnectionClientDelegate{
    
    let config : SparkBroadcastExtension.SparkBroadcastConfig
    var onError: ((SparkError) -> Void)?
    private var connectionClient: BroadcastConnectionClient?
    private var isStart: Bool = false
    
    init(broadcastConfig:SparkBroadcastExtension.SparkBroadcastConfig) {
        self.config = broadcastConfig
    }
    
    public func didReceivedError(_ error: ScreenShareError) {
        switch error {
        case .fatal:
            self.onError?(SparkError.serviceFailed(code: -7000, reason: "Spark Broadcast server fatal error"))
            break
        default:
            self.onError?(SparkError.serviceFailed(code: -7000, reason: "Spark Broadcast server fatal error"))
        }
    }
    
    func start(completionHandler: @escaping ((Error?) -> Void)) {
        if self.connectionClient == nil {
            self.connectionClient = BroadcastConnectionClient.init(applicationGroupIdentifier: self.config.applicationGroupIdentifier, delegate: self)
        }
        
        if self.isStart {
            completionHandler(nil)
            return
        }
        
        self.connectionClient?.start() {
            error in
            if error != nil {
                completionHandler(error)
            } else {
                self.isStart = true
                completionHandler(nil)
            }
        }
    }
    
    func pushVideoSampleBuffer(sampleBuffer:CMSampleBuffer) {
        if self.isStart {
            self.connectionClient?.push(sampleBuffer)
        }
    }
    
    func finishClient() {
        if self.isStart {
            var message = FrameMessage()
            message.error = ScreenShareError.stop;
            let data = Data(bytes: &message, count: MemoryLayout<FeedbackMessage>.size)
            self.connectionClient?.sendMessage(data) {
                error in
                if error != nil {
                    //add log
                }
            }
            self.connectionClient?.invalidate()
            self.isStart = false
        }
    }
}
