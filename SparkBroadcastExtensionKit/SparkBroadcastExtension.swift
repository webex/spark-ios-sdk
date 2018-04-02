//
//  SparkBroadcastExtension.swift
//  SparkBroadcastExtensionKit
//
//  Created by panzh on 17/03/2018.
//  Copyright © 2018 Cisco. All rights reserved.
//

import Foundation
import SparkSDKBroadcastUtil

@available (iOS 11.2,*)
public class SparkBroadcastExtension {
    
    public struct SparkBroadcastConfig {
        
        /// The application group identifier, share frame data from your app extension to its containing app.
        /// see the Apple documentation about how to adding an App to an App group.
        /// https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingAppSandbox.html#//apple_ref/doc/uid/TP40011195-CH4-SW19
        /// - since: 1.4.0
        public let applicationGroupIdentifier: String
        
        /// The date and time the access token will expire
        ///
        /// - since: 1.4.0
        public let maxSamplesPerSecond: Int
        
        public init(applicationGroupIdentifier:String,maxSamplesPerSecond:Int) {
            self.applicationGroupIdentifier = applicationGroupIdentifier
            self.maxSamplesPerSecond = maxSamplesPerSecond
        }
    }
    
    public static let sharedInstance = SparkBroadcastExtension()
    
    private var applicationGroupIdentifier: String?
    
    private var broadcastClient: SparkBroadcastClient?
    
    public var onError: ((SparkError) -> Void)? {
        didSet {
            self.broadcastClient?.onError = self.onError
        }
    }
    
    private init() {
        
    }
    
    public func start(broadcastConfig config:SparkBroadcastConfig,completionHandler: @escaping ((Error?) -> Void)) {
        if config.applicationGroupIdentifier.count > 0, self.broadcastClient == nil {
            self.broadcastClient = SparkBroadcastClient.init(broadcastConfig: config)
        }
        self.broadcastClient?.start(completionHandler: completionHandler)
    }
    
    public func handleVideoSampleBuffer(sampleBuffer:CMSampleBuffer) {
        self.broadcastClient?.pushVideoSampleBuffer(sampleBuffer: sampleBuffer)
    }
    
    public func finish() {
        self.broadcastClient?.finishClient()
    }
}

