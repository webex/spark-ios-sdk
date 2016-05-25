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
