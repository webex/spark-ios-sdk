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

struct DeviceRegistrationInformation {
    let deviceUrl: URL
    let webSocketUrl: URL
    let locusServiceUrl: URL
    let calliopeDiscoveryServiceUrl: URL
    let metricsServiceUrl: URL
}

class DeviceService {
    
    private let client: DeviceClient
    
    init(authenticationStrategy: AuthenticationStrategy) {
        client = DeviceClient(authenticationStrategy: authenticationStrategy)
    }

    var device: DeviceRegistrationInformation?
    
    var deviceUrl: String? {
        get {
            return UserDefaults.sharedInstance.deviceUrl
        }
        
        set {
            UserDefaults.sharedInstance.deviceUrl = newValue
        }
    }
    
    func registerDevice(_ completionHandler: @escaping (DeviceRegistrationInformation?) -> Void) {
        let registrationHandler = createRegistrationHandler(completionHandler)
        if let deviceUrl = deviceUrl {
            client.update(registeredDeviceUrl: deviceUrl, deviceInfo: UIDevice.current, completionHandler: registrationHandler)
        } else {
            client.create(deviceInfo: UIDevice.current, completionHandler: registrationHandler)
        }
    }
    
    func deregisterDevice(_ completionHandler: @escaping (Bool) -> Void) {
        if let deviceUrl = deviceUrl {
            client.delete(registeredDeviceUrl: deviceUrl) {
                (response: ServiceResponse<Any>) in
                self.onDeregisterDeviceCompleted(response, completionHandler: completionHandler)
            }
            self.deviceUrl = nil
        } else {
            completionHandler(true)
        }
    }
    
    private func createRegistrationHandler(_ completionHandler: @escaping (DeviceRegistrationInformation?) -> Void) -> ((ServiceResponse<Device>) -> Void) {
        return { serviceResponse in
            var deviceRegistrationInformation: DeviceRegistrationInformation?
            switch serviceResponse.result {
            case .success(let device):
                if let deviceUrlString = device.deviceUrl,
                    let deviceUrl = URL(string: deviceUrlString),
                    let webSocketUrlString = device.webSocketUrl,
                    let webSocketUrl = URL(string: webSocketUrlString),
                    let servicesDictionary = device.services,
                    let locusServiceUrlString = servicesDictionary["locusServiceUrl"],
                    let locusServiceUrl = URL(string: locusServiceUrlString),
                    let calliopeDiscoveryServiceUrlString = servicesDictionary["calliopeDiscoveryServiceUrl"],
                    let calliopeDiscoveryServiceUrl = URL(string: calliopeDiscoveryServiceUrlString),
                    let metricsServiceUrlString = servicesDictionary["metricsServiceUrl"],
                    let metricsServiceUrl = URL(string: metricsServiceUrlString) {
                    
                    deviceRegistrationInformation = DeviceRegistrationInformation(deviceUrl: deviceUrl, webSocketUrl: webSocketUrl, locusServiceUrl: locusServiceUrl, calliopeDiscoveryServiceUrl: calliopeDiscoveryServiceUrl, metricsServiceUrl: metricsServiceUrl)
                    self.device = deviceRegistrationInformation
                    self.deviceUrl = deviceUrlString
                } else {
                    Logger.error("Missing required URLs when registering device")
                }
            case .failure(let error):
                Logger.error("Failed to register device", error: error)
            }
            completionHandler(deviceRegistrationInformation)
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
}

