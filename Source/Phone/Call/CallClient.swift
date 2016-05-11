//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

// TODO: need to discuss if use term - "locus"
class CallClient: CompletionHandlerType<CallInfo>{
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().keyPath("locus")
    }
    
    func join(localInfo: HttpParameters, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .baseUrl(DeviceService.sharedInstance.getServiceUrl("locus")!)
            .body(localInfo)
            .path("loci/call")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func join(callUrl: String, localInfo: HttpParameters, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .body(localInfo)
            .path("participant")
            .baseUrl(callUrl)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func leave(participantUrl: String, deviceUrl: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .baseUrl(participantUrl)
            .path("leave")
            .body(HttpParameters(["deviceUrl": deviceUrl]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func decline(callUrl: String, deviceUrl: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .baseUrl(callUrl)
            .body(HttpParameters(["deviceUrl": deviceUrl]))
            .path("participant/decline")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func alert(participantUrl: String, deviceUrl: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler){
        let request = requestBuilder()
            .method(.PUT)
            .baseUrl(participantUrl)
            .body(HttpParameters(["deviceUrl": deviceUrl]))
            .path("alert")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func updateMedia(mediaUrl: String, localInfo: HttpParameters, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .baseUrl(mediaUrl)
            .body(localInfo)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func fetchCallInfo(callUrl: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .baseUrl(callUrl)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
}
