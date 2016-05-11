//
//  ServiceRequest.swift
//  Pods
//
//  Created by niliu2 on 3/12/16.
//
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class ServiceRequest {
    
    private var url: NSURL {
        return NSURL(string: baseUrl)!.URLByAppendingPathComponent(path)
    }
    
    private var headers: [String: String] {
        let authorization = AuthManager.sharedInstance.authorization()!
        let userAgent = UserAgent.sharedInstance.userAgentString
        return ["Content-Type": "application/json",
                "Authorization": authorization,
                "User-Agent": userAgent]
    }
    
    private var method = Method.GET
    private var baseUrl = "https://api.ciscospark.com/v1"
    private var path = ""
    private var body: HttpParameters?
    private var query: HttpParameters?
    private var keyPath: String?
    private var queue: dispatch_queue_t?
    
    class Builder {
        private var request = ServiceRequest()
        
        func build() -> ServiceRequest {
            return request
        }
        
        func method(method: Alamofire.Method) -> Builder {
            request.method = method
            return self
        }
        
        func baseUrl(baseUrl: String) -> Builder {
            request.baseUrl = baseUrl
            return self
        }
        
        func path(path: String) -> Builder {
            request.path += "/" + path
            return self
        }
        
        func body(body: HttpParameters) -> Builder {
            request.body = body
            return self
        }
        
        func query(query: HttpParameters) -> Builder {
            request.query = query
            return self
        }
        
        func keyPath(keyPath: String) -> Builder {
            request.keyPath = keyPath
            return self
        }
        
        func queue(queue: dispatch_queue_t?) -> Builder {
            request.queue = queue
            return self
        }
    }
    
    func responseObject<T: Mappable>(completionHandler: ServiceResponse<T> -> Void) {
        let requset = Alamofire.request(URLRequest()).validate()
        
        requset.responseObject(queue: queue, keyPath: keyPath) {
            (response: Response<T, NSError>) in
            var result: Result<T>
            
            switch response.result {
            case .Success(let value):
                result = .Success(value)
                
            case .Failure(var error):
                if response.response != nil {
                    if let data = response.data {
                        error = Error.requestErrorWithData(data)
                    }
                }
                result = .Failure(error)
            }
            
            completionHandler(ServiceResponse(response.response, result))
        }
    }
    
    func responseArray<T: Mappable>(completionHandler: ServiceResponse<[T]> -> Void){
        let requset = Alamofire.request(URLRequest()).validate()
        
        requset.responseArray(queue: queue, keyPath: keyPath){
            (response: Response<[T], NSError>) in
            var result: Result<[T]>
            
            switch response.result {
            case .Success(let value):
                result = .Success(value)
                
            case .Failure(var error):
                if response.response != nil {
                    if let data = response.data {
                        error = Error.requestErrorWithData(data)
                    }
                }
                result = .Failure(error)
            }
            
            completionHandler(ServiceResponse(response.response, result))
        }
    }
    
    func responseJSON(completionHandler: ServiceResponse<AnyObject> -> Void){
        let requset = Alamofire.request(URLRequest()).validate()
        
        requset.responseJSON(queue: queue){
            (response: Response<AnyObject, NSError>) in
            var result: Result<AnyObject>
            
            switch response.result {
            case .Success(let value):
                result = .Success(value)
                
            case .Failure(var error):
                if response.response != nil {
                    if let data = response.data {
                        error = Error.requestErrorWithData(data)
                    }
                }
                result = .Failure(error)
            }
            
            completionHandler(ServiceResponse(response.response, result))
        }
    }
    
    private func URLRequest() -> NSMutableURLRequest {
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        if let body = body {
            request = ParameterEncoding.JSON.encode(request, parameters: body.value()).0
        }
        if let query = query {
            request = ParameterEncoding.URL.encode(request, parameters: query.value()).0
        }
        
        return request
    }
}

