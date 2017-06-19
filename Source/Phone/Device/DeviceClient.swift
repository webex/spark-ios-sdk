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

class DeviceClient {
    
    private let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator)
    }
    
    func create(deviceInfo: UIDevice, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<DeviceModel>) -> Void) {
        let request = requestBuilder()
            .method(.post)
            .baseUrl("https://wdm-a.wbx2.com/wdm/api/v1/devices/ios")
            .body(createBody(deviceInfo))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func update(registeredDeviceUrl: String, deviceInfo: UIDevice, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<DeviceModel>) -> Void) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(registeredDeviceUrl)
            .body(createBody(deviceInfo))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func delete(registeredDeviceUrl: String, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = requestBuilder()
            .method(.delete)
            .baseUrl(registeredDeviceUrl)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    
    private func createBody(_ device: UIDevice) -> RequestParameter {
        let deviceName = device.name.isEmpty ? "notset" : device.name
        
        let deviceType: String
        if device.userInterfaceIdiom == .pad {
            deviceType = "IPAD"
        } else if device.userInterfaceIdiom == .phone {
            deviceType = "IPHONE"
        } else {
            deviceType = "UNKNOWN"
        }
        
        let deviceParameters:[String: Any] = [
            "deviceName": deviceName,
            "name": device.name,
            "model": device.model,
            "localizedModel": device.localizedModel,
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "deviceType": deviceType,
            "capabilities": ["sdpSupported":true, "groupCallSupported":true]]
        
        return RequestParameter(deviceParameters)
    }
   
}
