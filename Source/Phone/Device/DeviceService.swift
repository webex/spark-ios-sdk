// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    
    func getServiceUrl(service: String) -> String? {
        if let services = device?.services {
            return services[service + "ServiceUrl"]
        }
        
        return nil
    }
    
    func registerDevice(completionHandler: Bool -> Void) {
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
    
    func deregisterDevice(completionHandler: Bool -> Void) {
        if deviceUrl == nil {
            completionHandler(true)
            return
        }
        
        client.delete(deviceUrl!) {
            (response: ServiceResponse<AnyObject>) in
            self.onDeregisterDeviceCompleted(response, completionHandler: completionHandler)
        }
        
        UserDefaults.sharedInstance.removeDeviceUrl()
    }
    
    private func onRegisterDeviceCompleted(response: ServiceResponse<Device>, completionHandler: Bool -> Void) {
        switch response.result {
        case .Success(let value):
            self.device = value
            self.deviceUrl = self.device?.deviceUrl
            completionHandler(true)
        case .Failure(let error):
            Logger.error("Failed to register device: \(error.localizedFailureReason)")
            completionHandler(false)
        }
    }
    
    private func onDeregisterDeviceCompleted(response: ServiceResponse<AnyObject>, completionHandler: Bool -> Void) {
        switch response.result {
        case .Success:
            completionHandler(true)
        case .Failure(let error):
            Logger.error("Failed to deregister device: \(error.localizedFailureReason)")
            completionHandler(false)
        }
    }
    
    private func createDeviceInfo() -> RequestParameter {
        
        let currentDevice = UIDevice.currentDevice()
        var deviceName = currentDevice.name
        if (deviceName.isEmpty) {
            deviceName = "notset"
        }
        
        let deviceType = currentDevice.isiPad() ?  "IPAD" : "IPHONE"
        
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
}

