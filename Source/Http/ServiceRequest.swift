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
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SwiftyJSON

class ServiceRequest {
    
    private let url: URL
    private let headers: [String: String]
    private let method: Alamofire.HTTPMethod
    private let body: RequestParameter?
    private let query: RequestParameter?
    private let keyPath: String?
    private let queue: DispatchQueue?
    private let authenticator: Authenticator
    
#if INTEGRATIONTEST
    static let HYDRA_SERVER_ADDRESS:String = ProcessInfo().environment["HYDRA_SERVER_ADDRESS"] == nil ? "https://api.ciscospark.com/v1":ProcessInfo().environment["HYDRA_SERVER_ADDRESS"]!
#else
    static let HYDRA_SERVER_ADDRESS:String = "https://api.ciscospark.com/v1"
#endif
    
    
    private init(authenticator: Authenticator, url: URL, headers: [String: String], method: Alamofire.HTTPMethod, body: RequestParameter?, query: RequestParameter?, keyPath: String?, queue: DispatchQueue?) {
        self.authenticator = authenticator
        self.url = url
        self.headers = headers
        self.method = method
        self.body = body
        self.query = query
        self.keyPath = keyPath
        self.queue = queue
    }
    
    class Builder {
        
        private static let apiBaseUrl: URL = URL(string: ServiceRequest.HYDRA_SERVER_ADDRESS)!
        private let authenticator: Authenticator
        private var headers: [String: String]
        private var method: Alamofire.HTTPMethod
        private var baseUrl: URL
        private var path: String
        private var body: RequestParameter?
        private var query: RequestParameter?
        private var keyPath: String?
        private var queue: DispatchQueue?
        
        
        init(_ authenticator: Authenticator) {
            self.authenticator = authenticator
            self.headers = ["Content-Type": "application/json",
                            "User-Agent": UserAgent.string,
                            "Spark-User-Agent": UserAgent.string]
            self.baseUrl = Builder.apiBaseUrl
            self.method = .get
            self.path = ""
        }
        
        func build() -> ServiceRequest {
            return ServiceRequest(authenticator: authenticator, url: baseUrl.appendingPathComponent(path), headers: headers, method: method, body: body, query: query, keyPath: keyPath, queue: queue)
        }
        
        func method(_ method: Alamofire.HTTPMethod) -> Builder {
            self.method = method
            return self
        }
        
        func headers(_ headers: [String: String]) -> Builder {
            self.headers = headers
            return self
        }
        
        func baseUrl(_ baseUrl: String) -> Builder {
            self.baseUrl = URL(string: baseUrl)!
            return self
        }
        
        func baseUrl(_ baseUrl: URL) -> Builder {
            self.baseUrl = baseUrl
            return self
        }
        
        func path(_ path: String) -> Builder {
            self.path += "/" + path
            return self
        }
        
        func body(_ body: RequestParameter) -> Builder {
            self.body = body
            return self
        }
        
        func query(_ query: RequestParameter) -> Builder {
            self.query = query
            return self
        }
        
        func keyPath(_ keyPath: String) -> Builder {
            self.keyPath = keyPath
            return self
        }
        
        func queue(_ queue: DispatchQueue?) -> Builder {
            self.queue = queue
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
            var headers = self.headers
            if let accessToken = accessToken {
                headers["Authorization"] = "Bearer " + accessToken
            }
            
            let urlRequestConvertible: URLRequestConvertible
            do {
                var urlRequest = try URLRequest(url: self.url, method: self.method, headers: headers)
                //disable http local cache data.
                urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
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
        
        authenticator.accessToken { accessToken in
            accessTokenCallback(accessToken)
        }
    }
}

extension SparkError {
    
    /// Converts the error data to NSError
    static func requestErrorWith(data: Data) -> Error {
        var failureReason = "Service request failed without error message"
        if let errorMessage = JSON(data: data)["message"].string {
            failureReason = errorMessage
        }
        return SparkError.serviceFailed(code: -7000, reason: failureReason)
    }
    
}

