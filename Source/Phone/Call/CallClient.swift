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
    
    enum DialTarget {
        case peopleId(String)
        case peopleMail(String)
        case roomId(String)
        case roomMail(String)
        case other(String)
        
        var isEndpoint: Bool {
            switch self {
            case .peopleId(_), .peopleMail(_), .roomMail(_), .other(_):
                return true
            case .roomId(_):
                return false
            }
        }
        
        var isGroup: Bool {
            switch self {
            case .peopleId(_), .peopleMail(_), .other(_):
                return false
            case .roomId(_), .roomMail(_):
                return true
            }
        }
        
        var address: String {
            switch self {
            case .peopleId(let id):
                return id
            case .peopleMail(let mail):
                return mail
            case .roomId(let id):
                return id
            case .roomMail(let mail):
                return mail
            case .other(let other):
                return other
            }
        }
        
        static func lookup(_ address: String, by spark: Spark, completionHandler: @escaping (DialTarget) -> Void) {
            if let target = parseHydraId(id: address) {
                completionHandler(target)
            }
            else if let email = EmailAddress.fromString(address) {
                if address.lowercased().hasSuffix("@meet.ciscospark.com") {
                    completionHandler(DialTarget.roomMail(address))
                }
                else if address.contains("@") && !address.contains(".") {
                    spark.people.list(email: email, displayName: nil, max: 1) { persons in
                        if let id = persons.result.data?.first?.id, let target = parseHydraId(id: id) {
                            completionHandler(target)
                        }
                        else {
                            completionHandler(DialTarget.peopleMail(address))
                        }
                    }
                }
                else {
                    completionHandler(DialTarget.peopleMail(address))
                }
            }
            else {
                completionHandler(DialTarget.other(address))
            }
        }
        
        private static func parseHydraId(id: String) -> DialTarget? {
            if let decode = id.base64Decoded(), let uri = URL(string: decode), uri.scheme == "ciscospark" {
                let path = uri.pathComponents
                if path.count > 2 {
                    let type = path[path.count - 2]
                    if type == "PEOPLE" {
                        return DialTarget.peopleId(path[path.count - 1])
                    }
                    else if type == "ROOM" {
                        return DialTarget.roomId(path[path.count - 1])
                    }
                }
            }
            return nil
        }
    }
    
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

    private func body(device: Device, json: [String:Any?] = [:]) -> RequestParameter {
        var result = json
        result["device"] = ["url":device.deviceUrl.absoluteString, "deviceType":device.deviceType, "regionCode":device.countryCode, "countryCode":device.regionCode]        
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
            .body(body(device: device, json: json))
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
            .body(body(device: device, json: json))
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
