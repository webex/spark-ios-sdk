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

class DeviceClient: CompletionHandlerType<Device> {
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().baseUrl("https://wdm-a.wbx2.com/wdm/api/v1/devices/ios")
    }
    
    func create(deviceInfo: RequestParameter, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .body(deviceInfo)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func update(deviceUrl: String, deviceInfo: RequestParameter, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .baseUrl(deviceUrl)
            .body(deviceInfo)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func delete(deviceUrl: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .baseUrl(deviceUrl)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}
