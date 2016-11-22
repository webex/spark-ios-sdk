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
    
    private var url: URL {
        return URL(string: baseUrl)!.appendingPathComponent(path)
    }
    
    private var headers: [String: String]
    private var method: Alamofire.HTTPMethod
    private var baseUrl: String
    private var path: String
    private var authRequired: Bool
    private var body: RequestParameter?
    private var query: RequestParameter?
    private var keyPath: String?
    private var queue: DispatchQueue?
    
    
    init() {
        let userAgent = UserAgent.sharedInstance.userAgentString
        self.headers = ["Content-Type": "application/json",
                        "User-Agent": userAgent]
        
        self.authRequired = true
        self.baseUrl = "https://api.ciscospark.com/v1"
        self.method = .get
        self.path = ""
    }
    
    class Builder {
        private var request = ServiceRequest()
        
        func build() -> ServiceRequest {
            return request
        }
        
        func method(_ method: Alamofire.HTTPMethod) -> Builder {
            request.method = method
            return self
        }
        
        func headers(_ headers: [String: String]) -> Builder {
            request.headers = headers
            return self
        }
        
        func baseUrl(_ baseUrl: String) -> Builder {
            request.baseUrl = baseUrl
            return self
        }
        
        func path(_ path: String) -> Builder {
            request.path += "/" + path
            return self
        }
        
        func body(_ body: RequestParameter) -> Builder {
            request.body = body
            return self
        }
        
        func query(_ query: RequestParameter) -> Builder {
            request.query = query
            return self
        }
        
        func keyPath(_ keyPath: String) -> Builder {
            request.keyPath = keyPath
            return self
        }
        
        func queue(_ queue: DispatchQueue?) -> Builder {
            request.queue = queue
            return self
        }
        
        func authRequired(_ authRequired: Bool) -> Builder {
            request.authRequired = authRequired
            return self
        }
    }
    
    func responseObject<T: Mappable>(_ completionHandler: @escaping (ServiceResponse<T>) -> Void) {
        let queue = self.queue
        let keyPath = self.keyPath
        createAlamofireRequest() { request in             
            request.responseObject(queue: queue, keyPath: keyPath) {
                (response: DataResponse<T>) in
                var result: Result<T>
                
                switch response.result {
                case .success(let value):
                    result = .success(value)
                    
                case .failure(var error):
                    if response.response != nil {
                        if let data = response.data {
                            error = SparkError.requestErrorWith(data: data)
                        }
                    }
                    result = .failure(error)
                }
                
                completionHandler(ServiceResponse(response.response, result))
            }
        }
    }
    
    func responseArray<T: Mappable>(_ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) {
        let queue = self.queue
        let keyPath = self.keyPath
        createAlamofireRequest() { request in         
            request.responseArray(queue: queue, keyPath: keyPath) {
                (response: DataResponse<[T]>) in
                var result: Result<[T]>
                
                switch response.result {
                case .success(let value):
                    result = .success(value)
                    
                case .failure(var error):
                                            if response.response != nil {
                        if let data = response.data {
                            error = SparkError.requestErrorWith(data: data)
                        }
                    }
                    result = .failure(error)
                }
                
                completionHandler(ServiceResponse(response.response, result))
            }
        }
    }
    
    func responseJSON(_ completionHandler: @escaping (ServiceResponse<Any>) -> Void) {
        let queue = self.queue
        createAlamofireRequest() { request in         
            request.responseJSON(queue: queue) {
                (response: DataResponse<Any>) in
                var result: Result<Any>
                
                switch response.result {
                case .success(let value):
                    result = .success(value)
                    
                case .failure(var error):
                    if response.response != nil {
                        if let data = response.data {
                            error = SparkError.requestErrorWith(data: data)
                        }
                    }
                    result = .failure(error)
                }
                
                completionHandler(ServiceResponse(response.response, result))
            }   
        }
    }
    
    private func createAlamofireRequest(completionHandler: @escaping (Alamofire.DataRequest) -> Void) {
        let accessTokenCallback: (String?) -> Void = { accessToken in 
            if let accessToken = accessToken {
                self.headers["Authorization"] = "Bearer " + accessToken
            }
            
            let urlRequestConvertible: URLRequestConvertible
            do {
                var urlRequest = try URLRequest(url: self.url, method: self.method, headers: self.headers)
                if let body = self.body {
                    urlRequest = try JSONEncoding.default.encode(urlRequest, with: body.value())
                }
                if let query = self.query {
                    urlRequest = try URLEncoding.default.encode(urlRequest, with: query.value())
                }
                urlRequestConvertible = urlRequest
            } catch {
                class ErrorRequestConvertible : URLRequestConvertible {
                    private let error: Error
                    init(_ error: Error) {
                        self.error = error
                    }
                    
                    func asURLRequest() throws -> URLRequest {
                        throw self.error
                    }
                }
                urlRequestConvertible = ErrorRequestConvertible(error)
            }
            
            completionHandler(Alamofire.request(urlRequestConvertible).validate())
        }
        
        if authRequired {
            AuthManager.sharedInstance.accessToken { (accessToken) in
                accessTokenCallback(accessToken)
            }
        } else {
            accessTokenCallback(nil)
        }
    }
}

