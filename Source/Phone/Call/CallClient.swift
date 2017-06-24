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
import ObjectMapper

class CallClient {
    
    private let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).keyPath("locus")
    }
    
    private func body(deviceUrl: URL, json: [String:Any?] = [:]) -> RequestParameter {
        var result = json
        result["deviceUrl"] = deviceUrl.absoluteString
        return RequestParameter(result)
    }
    
    private func convertToJson(_ mediaID: String? = nil, mediaInfo: MediaModel) -> [String:Any?] {
        let mediaInfoJSON = Mapper().toJSONString(mediaInfo, prettyPrint: true)!
        if let id = mediaID {
            return ["localMedias": [["mediaId":id ,"type": "SDP", "localSdp": mediaInfoJSON]]]
        }
        return ["localMedias": [["type": "SDP", "localSdp": mediaInfoJSON]]]
    }
    
    func create(_ toAddress: String, by device: Device, localMedia: MediaModel, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        var json = convertToJson(mediaInfo: localMedia)
        json["invitee"] = ["address" : toAddress]

        let request = requestBuilder()
            .method(.post)
            .baseUrl(device.locusServiceUrl)
            .path("loci/call")
            .body(body(deviceUrl: device.deviceUrl, json: json))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func join(_ callUrl: String, by device: Device, localMedia: MediaModel, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        let json = convertToJson(mediaInfo: localMedia)
        let request = requestBuilder()
            .method(.post)
            .baseUrl(callUrl)
            .path("participant")
            .body(body(deviceUrl: device.deviceUrl, json: json))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func leave(_ participantUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(participantUrl)
            .path("leave")
            .body(body(deviceUrl: device.deviceUrl))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func decline(_ callUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(callUrl)
            .body(body(deviceUrl: device.deviceUrl))
            .path("participant/decline")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }

    func alert(_ callUrl: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let request = requestBuilder()
            .method(.put)
            .baseUrl(callUrl)
            .body(body(deviceUrl: device.deviceUrl))
            .path("participant/alert")
            .queue(queue)
            .build()
    
        request.responseJSON(completionHandler)
    }
    
    func sendDtmf(_ participantUrl: String, by device: Device, correlationId: Int, events: String, volume: Int? = nil, durationMillis: Int? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
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
            .body(body(deviceUrl: device.deviceUrl, json: json))
            .path("sendDtmf")
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
    
    func update(_ mediaUrl: String,by mediaID: String, by device: Device, localMedia: MediaModel, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        let json = convertToJson(mediaID,mediaInfo: localMedia)
        let request = requestBuilder()
            .method(.put)
            .baseUrl(mediaUrl)
            .body(body(deviceUrl: device.deviceUrl, json: json))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func fetch(_ callUrl: String, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<CallModel>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .baseUrl(callUrl)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func fetch(by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<[CallModel]>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .baseUrl(device.locusServiceUrl)
            .path("loci")
            .keyPath("loci")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
}
