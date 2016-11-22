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
class CallClient {
	typealias ObjectHandler = (ServiceResponse<CallInfo>) -> Void
	typealias ArrayHandler = (ServiceResponse<[CallInfo]>) -> Void
	
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().keyPath("locus")
    }
    
    func join(_ localInfo: RequestParameter, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.post)
            .baseUrl(DeviceService.sharedInstance.getServiceUrl("locus")!)
            .body(localInfo)
            .path("loci/call")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func join(_ callUrl: String, localInfo: RequestParameter, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.post)
            .body(localInfo)
            .path("participant")
            .baseUrl(callUrl)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func leave(_ participantUrl: String, deviceUrl: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(participantUrl)
            .path("leave")
            .body(RequestParameter(["deviceUrl": deviceUrl]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func decline(_ callUrl: String, deviceUrl: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(callUrl)
            .body(RequestParameter(["deviceUrl": deviceUrl]))
            .path("participant/decline")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func alert(_ participantUrl: String, deviceUrl: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(participantUrl)
            .body(RequestParameter(["deviceUrl": deviceUrl]))
            .path("alert")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func sendDtmf(_ participantUrl: String, deviceUrl: String, correlationId: Int, events: String, volume: Int? = nil, durationMillis: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        var dtmfInfo: [String:Any] = [
            "tones": events,
            "correlationId": correlationId]
        if volume != nil {
            dtmfInfo["volume"] = volume
        }
        if durationMillis != nil {
            dtmfInfo["durationMillis"] = durationMillis
        }
        let body:[String: Any] = [
            "deviceUrl": deviceUrl,
            "dtmf": dtmfInfo]
        
        let request = requestBuilder()
            .method(.post)
            .baseUrl(participantUrl)
            .body(RequestParameter(body))
            .path("sendDtmf")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func updateMedia(_ mediaUrl: String, localInfo: RequestParameter, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(mediaUrl)
            .body(localInfo)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func fetchCallInfo(_ callUrl: String, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.get)
            .baseUrl(callUrl)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func fetchCallInfos(_ queue: DispatchQueue? = nil, completionHandler: @escaping ArrayHandler) {
        let request = requestBuilder()
            .method(.get)
            .baseUrl(DeviceService.sharedInstance.getServiceUrl("locus")!)
            .path("loci")
            .keyPath("loci")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
}
