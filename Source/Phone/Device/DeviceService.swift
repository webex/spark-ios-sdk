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

class DeviceService: CompletionHandlerType<Device> {
    static let sharedInstance = DeviceService()
    
    private var device: Device?
    private let client: DeviceClient = DeviceClient()
    
    var deviceUrl: String? {
        get {
            return UserDefaults.sharedInstance.deviceUrl
        }
        
        set {
            UserDefaults.sharedInstance.deviceUrl = newValue
        }
    }
    
    var webSocketUrl: String? {
        return device?.webSocketUrl
    }
    
    func getServiceUrl(_ service: String) -> String? {
        if let services = device?.services {
            return services[service + "ServiceUrl"]
        }
        
        return nil
    }
    
    func registerDevice(_ completionHandler: @escaping (Bool) -> Void) {
        let deviceInfo = createDeviceInfo()
        if deviceUrl == nil {
            client.create(deviceInfo) {
                (response: ServiceResponse<Device>) in
                self.onRegisterDeviceCompleted(response, completionHandler: completionHandler)
            }
            
        } else {
            client.update(deviceUrl!, deviceInfo: deviceInfo) {
                (response: ServiceResponse<Device>) in
                self.onRegisterDeviceCompleted(response, completionHandler: completionHandler)
            }
        }
    }
    
    func deregisterDevice(_ completionHandler: @escaping (Bool) -> Void) {
        if deviceUrl == nil {
            completionHandler(true)
            return
        }
        
        client.delete(deviceUrl!) {
            (response: ServiceResponse<Any>) in
            self.onDeregisterDeviceCompleted(response, completionHandler: completionHandler)
        }
        
        deviceUrl = nil
    }
    
    private func onRegisterDeviceCompleted(_ response: ServiceResponse<Device>, completionHandler: (Bool) -> Void) {
        switch response.result {
        case .success(let value):
            self.device = value
            self.deviceUrl = self.device?.deviceUrl
            completionHandler(true)
        case .failure(let error):
            Logger.error("Failed to register device: \(error.localizedFailureReason)")
            completionHandler(false)
        }
    }
    
    private func onDeregisterDeviceCompleted(_ response: ServiceResponse<Any>, completionHandler: (Bool) -> Void) {
        switch response.result {
        case .success:
            completionHandler(true)
        case .failure(let error):
            Logger.error("Failed to deregister device: \(error.localizedFailureReason)")
            completionHandler(false)
        }
    }
    
    private func createDeviceInfo() -> RequestParameter {
        
        let currentDevice = UIDevice.current
        var deviceName = currentDevice.name
        if (deviceName.isEmpty) {
            deviceName = "notset"
        }
        
        var deviceType = "UNKNOWN"
        if isPad() {
            deviceType = "IPAD"
        } else if isPhone() {
            deviceType = "IPHONE"
        }
        
        let deviceParameters:[String: Any?] = [
            "deviceName": deviceName,
            "name": currentDevice.name,
            "model": currentDevice.model,
            "localizedModel": currentDevice.localizedModel,
            "systemName": currentDevice.systemName,
            "systemVersion": currentDevice.systemVersion,
            "deviceType": deviceType,
            "capabilities": ["sdpSupported":true, "groupCallSupported":true]]
        
        return RequestParameter(deviceParameters)
    }
    
    private func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    private func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
}

