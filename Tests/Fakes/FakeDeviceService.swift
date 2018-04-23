// Copyright 2016-2018 Cisco Systems Inc
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
