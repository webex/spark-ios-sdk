//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class DeviceClient: CompletionHandlerType<Device> {
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().baseUrl("https://wdm-a.wbx2.com/wdm/api/v1/devices/ios")
    }
    
    func create(deviceInfo: HttpParameters, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .body(deviceInfo)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func update(deviceUrl: String, deviceInfo: HttpParameters, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
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
