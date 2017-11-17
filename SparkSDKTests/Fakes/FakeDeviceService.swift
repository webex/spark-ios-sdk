//
//  FakeDeviceService.swift
//  SparkSDKTests
//
//  Created by panzh on 08/11/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
@testable import SparkSDK

class FakeDeviceService: DeviceService {
    var disableRegister: Bool = false
    var disableDeregister: Bool = false
    override func registerDevice(phone: Phone, queue: DispatchQueue, completionHandler: @escaping (Result<Device>) -> Void) {
        if disableRegister == false {
        let deviceUrl = URL(string: Config.FakeSelfDeviceUrl)
        
        let webSocketUrl = URL(string: Config.FakeWebSocketUrl)
        
        
        let locusServiceUrl = URL(string: Config.FakeLocusServiceUrl)
        
        let conversationServiceUrl = URL(string: Config.FakeConversationServiceUrl)
        
        let calliopeDiscoveryServiceUrl = URL(string: Config.FakeCalliopeDiscoveryServiceUrl)
        
        let metricsServiceUrl = URL(string: Config.FakeMetricsServiceUrl)
        
        let regionCode = "US-WEST";
        let countryCode = "US";
        
        let device = Device(phone: phone, deviceUrl: deviceUrl!, webSocketUrl: webSocketUrl!, locusServiceUrl: locusServiceUrl!, calliopeDiscoveryServiceUrl: calliopeDiscoveryServiceUrl!, metricsServiceUrl: metricsServiceUrl!, conversationServiceUrl: conversationServiceUrl!, deviceType: "IPHONE", regionCode: regionCode, countryCode: countryCode)
        
        self.device = device
        UserDefaults.sharedInstance.deviceUrl = Config.FakeSelfDeviceUrl
            completionHandler(Result.success(device))
            
        }
        else {
            let error = SparkError.serviceFailed(code: -7000, reason: "registering device error")
            completionHandler(Result.failure(error))
            self.disableRegister = false
        }
        
    }
    
    override func deregisterDevice(queue: DispatchQueue, completionHandler: @escaping (Error?) -> Void) {
        if disableDeregister == false {
            completionHandler(nil)
            
        }
        else {
            
            completionHandler(SparkError.serviceFailed(code: -7000, reason: "deregistering device error"))
            disableDeregister = false
            
        }
        UserDefaults.sharedInstance.deviceUrl = nil
        self.device = nil
    }
    
}
