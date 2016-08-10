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
    
    func sendDtmf(participantUrl: String, deviceUrl: String, correlationId: Int, events: String, volume: Int? = nil, durationMillis: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        var dtmfInfo: [String: AnyObject] = [
            "tones": events,
            "correlationId": correlationId]
        if volume != nil {
            dtmfInfo["volume"] = volume
        }
        if durationMillis != nil {
            dtmfInfo["durationMillis"] = durationMillis
        }
        let body:[String: Any?] = [
            "deviceUrl": deviceUrl,
            "dtmf": dtmfInfo]
        
        let request = requestBuilder()
            .method(.POST)
            .baseUrl(participantUrl)
            .body(RequestParameter(body))
            .path("sendDtmf")
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
    
    func fetchCallInfos(queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .baseUrl(DeviceService.sharedInstance.getServiceUrl("locus")!)
            .path("loci")
            .keyPath("loci")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
}
