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

class DeviceService {
    
    private var device: Device?
    private let client: DeviceClient
    
    init(authenticationStrategy: AuthenticationStrategy) {
        client = DeviceClient(authenticationStrategy: authenticationStrategy)
    }
    
    var deviceUrl: String? {
        get {
            return UserDefaults.sharedInstance.deviceUrl
        }
        
        set {
            UserDefaults.sharedInstance.deviceUrl = newValue
        }
    }
    
    var webSocketUrl: URL? {
        if let urlString = device?.webSocketUrl {
            return URL(string: urlString)
        }
        return nil
    }
    
    func getServiceUrl(_ service: String) -> String? {
        if let services = device?.services {
            return services[service + "ServiceUrl"]
        }
        
        return nil
    }
    
    func registerDevice(_ completionHandler: @escaping (Bool) -> Void) {
        let deviceInfo = createDeviceInfo()

        if let deviceUrl = deviceUrl {
            client.update(deviceUrl, deviceInfo: deviceInfo) {
                (response: ServiceResponse<Device>) in
                self.onRegisterDeviceCompleted(response, completionHandler: completionHandler)
            }
        } else {
            client.create(deviceInfo) {
                (response: ServiceResponse<Device>) in
                self.onRegisterDeviceCompleted(response, completionHandler: completionHandler)
            }
        }
    }
    
    func deregisterDevice(_ completionHandler: @escaping (Bool) -> Void) {
        if let deviceUrl = deviceUrl {
            client.delete(deviceUrl) {
                (response: ServiceResponse<Any>) in
                self.onDeregisterDeviceCompleted(response, completionHandler: completionHandler)
            }
            self.deviceUrl = nil
        } else {
            completionHandler(true)
            return
        }
    }

    private func onRegisterDeviceCompleted(_ response: ServiceResponse<Device>, completionHandler: (Bool) -> Void) {
        switch response.result {
        case .success(let device):
            if let deviceUrl = device.deviceUrl {
                self.device = device
                self.deviceUrl = deviceUrl
                completionHandler(true)
            } else {
                Logger.error("Missing device URL when registering device")
                completionHandler(false)
            }
        case .failure(let error):
            Logger.error("Failed to register device", error: error)
            completionHandler(false)
        }
    }
    
    private func onDeregisterDeviceCompleted(_ response: ServiceResponse<Any>, completionHandler: (Bool) -> Void) {
        switch response.result {
        case .success:
            completionHandler(true)
        case .failure(let error):
            Logger.error("Failed to deregister device", error: error)
            completionHandler(false)
        }
    }
    
    private func createDeviceInfo() -> RequestParameter {
        
        let currentDevice = UIDevice.current
        let deviceName = currentDevice.name.isEmpty ? "notset" : currentDevice.name
        
        let deviceType: String
        if isPad() {
            deviceType = "IPAD"
        } else if isPhone() {
            deviceType = "IPHONE"
        } else {
            deviceType = "UNKNOWN"
        }
        
        let deviceParameters:[String: Any] = [
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

