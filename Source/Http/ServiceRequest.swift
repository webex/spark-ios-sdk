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
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class ServiceRequest {
    
    private var url: NSURL {
        return NSURL(string: baseUrl)!.URLByAppendingPathComponent(path)
    }
    
    private var headers: [String: String]
    private var method: Alamofire.Method
    private var baseUrl: String
    private var path: String
    private var authRequired: Bool
    private var body: RequestParameter?
    private var query: RequestParameter?
    private var keyPath: String?
    private var queue: dispatch_queue_t?
    
    
    init() {
        let userAgent = UserAgent.sharedInstance.userAgentString
        self.headers = ["Content-Type": "application/json",
                        "User-Agent": userAgent]
        
        self.authRequired = true
        self.baseUrl = "https://api.ciscospark.com/v1"
        self.method = .GET
        self.path = ""
    }
    
    class Builder {
        private var request = ServiceRequest()
        
        func build() -> ServiceRequest {
            return request
        }
        
        func method(method: Alamofire.Method) -> Builder {
            request.method = method
            return self
        }
        
        func headers(headers: [String: String]) -> Builder {
            request.headers = headers
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
        
        func body(body: RequestParameter) -> Builder {
            request.body = body
            return self
        }
        
        func query(query: RequestParameter) -> Builder {
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
        
        func authRequired(authRequired: Bool) -> Builder {
            request.authRequired = authRequired
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
        
        if authRequired {
            if let authorization = AuthManager.sharedInstance.getAuthorization() {
                headers.unionInPlace(authorization)
            }
        }
        
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

