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
import ObjectMapper


// TODO: need to discuss if use term - "locus"
class CallClient {
    
    typealias ObjectHandler = (ServiceResponse<CallInfo>) -> Void
    typealias ArrayHandler = (ServiceResponse<[CallInfo]>) -> Void
    
    private let authenticationStrategy: AuthenticationStrategy
    private let deviceService: DeviceService
    
    init(authenticationStrategy: AuthenticationStrategy, deviceService: DeviceService) {
        self.authenticationStrategy = authenticationStrategy
        self.deviceService = deviceService
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticationStrategy).keyPath("locus")
    }
    
    private func body(deviceUrl: URL, json: [String:Any?] = [:]) -> RequestParameter {
        var result = json
        result["deviceUrl"] = deviceUrl.absoluteString
        return RequestParameter(result)
    }
    
    private func convertToJson(mediaInfo: MediaInfo) -> [String:Any?] {
        let mediaInfoJSON = Mapper().toJSONString(mediaInfo, prettyPrint: true)!
        return ["localMedias": [["type": "SDP", "localSdp": mediaInfoJSON]]]
    }
    
    func createCall(toAddress: String, deviceUrl: URL, localMediaInfo: MediaInfo, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        var json = convertToJson(mediaInfo: localMediaInfo)
        json["invitee"] = ["address" : toAddress]

        let request = requestBuilder()
            .method(.post)
            .baseUrl(deviceService.device!.locusServiceUrl)
            .path("loci/call")
            .body(body(deviceUrl: deviceUrl, json: json))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func joinExistingCall(callUrl: String, deviceUrl: URL, localMediaInfo: MediaInfo, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let json = convertToJson(mediaInfo: localMediaInfo)
        let request = requestBuilder()
            .method(.post)
            .baseUrl(callUrl)
            .path("participant")
            .body(body(deviceUrl: deviceUrl, json: json))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func leave(participantUrl: String, deviceUrl: URL, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(participantUrl)
            .path("leave")
            .body(body(deviceUrl: deviceUrl))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func decline(callUrl: String, deviceUrl: URL, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(callUrl)
            .body(body(deviceUrl: deviceUrl))
            .path("participant/decline")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }

// Unused functionality
//    func alert(_ participantUrl: String, deviceUrl: String, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
//        let request = requestBuilder()
//            .method(.put)
//            .baseUrl(participantUrl)
//            .body(RequestParameter(["deviceUrl": deviceUrl]))
//            .path("alert")
//            .queue(queue)
//            .build()
//        
//        request.responseJSON(completionHandler)
//    }
    
    func sendDtmf(_ participantUrl: String, deviceUrl: URL, correlationId: Int, events: String, volume: Int? = nil, durationMillis: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping AnyHandler) {
        var dtmfInfo: [String:Any] = [
            "tones": events,
            "correlationId" : correlationId]
        if let volume = volume {
            dtmfInfo["volume"] = volume
        }
        if let durationMillis = durationMillis {
            dtmfInfo["durationMillis"] = durationMillis
        }
        let json: [String: Any] = ["dtmf" : dtmfInfo]
        
        let request = requestBuilder()
            .method(.post)
            .baseUrl(participantUrl)
            .body(body(deviceUrl: deviceUrl, json: json))
            .path("sendDtmf")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func updateMedia(_ mediaUrl: String, deviceUrl: URL, localMediaInfo: MediaInfo, queue: DispatchQueue? = nil, completionHandler: @escaping ObjectHandler) {
        let json = convertToJson(mediaInfo: localMediaInfo)
        let request = requestBuilder()
            .method(.put)
            .baseUrl(mediaUrl)
            .body(body(deviceUrl: deviceUrl, json: json))
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
            .baseUrl(deviceService.device!.locusServiceUrl)
            .path("loci")
            .keyPath("loci")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
}
