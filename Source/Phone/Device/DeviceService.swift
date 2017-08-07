// Copyright 2016-2017 Cisco Systems Inc
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

struct Device {
    let phone: Phone
    let deviceUrl: URL
    let webSocketUrl: URL
    let locusServiceUrl: URL
    let calliopeDiscoveryServiceUrl: URL
    let metricsServiceUrl: URL
    let deviceType:String
    var regionCode: String
    var countryCode: String
}

class DeviceService {
    
    private let client: DeviceClient
    
    init(authenticator: Authenticator) {
        client = DeviceClient(authenticator: authenticator)
    }

    var device: Device?
    
    func registerDevice(phone: Phone, queue: DispatchQueue, completionHandler: @escaping (Result<Device>) -> Void) {
        
        let registrationHandler: (ServiceResponse<DeviceModel>) -> Void = { response in
            switch response.result {
            case .success(let model):
                if let deviceUrlString = model.deviceUrl,
                    let deviceUrl = URL(string: deviceUrlString),
                    let webSocketUrlString = model.webSocketUrl,
                    let webSocketUrl = URL(string: webSocketUrlString),
                    let servicesDictionary = model.services,
                    let locusServiceUrlString = servicesDictionary["locusServiceUrl"],
                    let locusServiceUrl = URL(string: locusServiceUrlString),
                    let calliopeDiscoveryServiceUrlString = servicesDictionary["calliopeDiscoveryServiceUrl"],
                    let calliopeDiscoveryServiceUrl = URL(string: calliopeDiscoveryServiceUrlString),
                    let metricsServiceUrlString = servicesDictionary["metricsServiceUrl"],
                    let metricsServiceUrl = URL(string: metricsServiceUrlString) {
                    
                    self.client.fetchRegion(queue: queue) { regionRes in
                        var regionCode = "US-WEST";
                        var countryCode = "US";
                        if let model = regionRes.result.data, let rc = model.regionCode, let cc = model.countryCode {
                            regionCode = rc
                            countryCode = cc
                        }
                        let device = Device(phone: phone, deviceUrl: deviceUrl, webSocketUrl: webSocketUrl, locusServiceUrl: locusServiceUrl, calliopeDiscoveryServiceUrl: calliopeDiscoveryServiceUrl, metricsServiceUrl: metricsServiceUrl, deviceType: UIDevice.current.kind, regionCode: regionCode, countryCode: countryCode)
                        self.device = device
                        UserDefaults.sharedInstance.deviceUrl = deviceUrlString
                        completionHandler(Result.success(device))
                    }
                    
                } else {
                    let error = SparkError.serviceFailed(code: -7000, reason: "Missing required URLs when registering device")
                    SDKLogger.shared.error("Failed to register device", error: error)
                    completionHandler(Result.failure(error))
                }
            case .failure(let error):
                SDKLogger.shared.error("Failed to register device", error: error)
                completionHandler(Result.failure(error))
            }
        }
        
        if let deviceUrl = UserDefaults.sharedInstance.deviceUrl {
            self.client.update(registeredDeviceUrl: deviceUrl, deviceInfo: UIDevice.current, queue: queue, completionHandler: registrationHandler)
        }
        else {
            self.client.create(deviceInfo: UIDevice.current, queue: queue, completionHandler: registrationHandler)
        }
    }
    
    func deregisterDevice(queue: DispatchQueue, completionHandler: @escaping (Error?) -> Void) {
        if let deviceUrl = UserDefaults.sharedInstance.deviceUrl {
            self.client.delete(registeredDeviceUrl: deviceUrl, queue: queue) { (response: ServiceResponse<Any>) in
                switch response.result {
                case .success:
                    completionHandler(nil)
                case .failure(let error):
                    SDKLogger.shared.error("Failed to deregister device", error: error)
                    completionHandler(error)
                }
            }
            UserDefaults.sharedInstance.deviceUrl = nil
        } else {
            completionHandler(nil)
        }
        self.device = nil
    }
}

fileprivate extension UIDevice {
    
    var kind: String {
        if self.userInterfaceIdiom == .pad {
            return "IPAD"
        } else if self.userInterfaceIdiom == .phone {
            return "IPHONE"
        } else {
            return "UNKNOWN"
        }
    }
    
}

