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

// TODO: need to discuss if use term - "locus"
class CallClient: CompletionHandlerType<CallInfo>{
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().keyPath("locus")
    }
    
    func join(localInfo: RequestParameter, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .baseUrl(DeviceService.sharedInstance.getServiceUrl("locus")!)
            .body(localInfo)
            .path("loci/call")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func join(callUrl: String, localInfo: RequestParameter, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
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
            .body(RequestParameter(["deviceUrl": deviceUrl]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func decline(callUrl: String, deviceUrl: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .baseUrl(callUrl)
            .body(RequestParameter(["deviceUrl": deviceUrl]))
            .path("participant/decline")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func alert(participantUrl: String, deviceUrl: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler){
        let request = requestBuilder()
            .method(.PUT)
            .baseUrl(participantUrl)
            .body(RequestParameter(["deviceUrl": deviceUrl]))
            .path("alert")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func updateMedia(mediaUrl: String, localInfo: RequestParameter, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
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
