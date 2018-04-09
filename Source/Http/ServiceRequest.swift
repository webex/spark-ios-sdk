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

class ServiceRequest : RequestRetrier, RequestAdapter{
    private var pendingTimeCount : Int = 0
    private let url: URL
    private let headers: [String: String]
    private let method: Alamofire.HTTPMethod
    private let body: RequestParameter?
    private let query: RequestParameter?
    private let keyPath: String?
    private let queue: DispatchQueue?
    private let authenticator: Authenticator
    private var newAccessToken: String? = nil
    private var refreshTokenCount = 0
    #if INTEGRATIONTEST
    static let HYDRA_SERVER_ADDRESS:String = ProcessInfo().environment["HYDRA_SERVER_ADDRESS"] == nil ? "https://api.ciscospark.com/v1":ProcessInfo().environment["HYDRA_SERVER_ADDRESS"]!
    #else
    static let HYDRA_SERVER_ADDRESS:String = "https://api.ciscospark.com/v1"
    #endif
    static let CONVERSATION_SERVER_ADDRESS: String = "https://conv-a.wbx2.com/conversation/api/v1"
    
    static let KMS_SERVER_ADDRESS: String = "https://encryption-a.wbx2.com/encryption/api/v1"
    
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
    
    class MessageServerBuilder{
        private static let apiBaseUrl: URL = URL(string: ServiceRequest.CONVERSATION_SERVER_ADDRESS)!
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
            self.baseUrl = MessageServerBuilder.apiBaseUrl
            self.method = .get
            self.path = ""
        }
        
        func build() -> ServiceRequest {
            return ServiceRequest(authenticator: authenticator, url: baseUrl.appendingPathComponent(path), headers: headers, method: method, body: body, query: query, keyPath: keyPath, queue: queue)
        }
        
        func method(_ method: Alamofire.HTTPMethod) -> MessageServerBuilder {
            self.method = method
            return self
        }
        
        func headers(_ headers: [String: String]) -> MessageServerBuilder {
            self.headers = headers
            return self
        }
        
        func baseUrl(_ baseUrl: String) -> MessageServerBuilder {
            self.baseUrl = URL(string: baseUrl)!
            return self
        }
        
        func baseUrl(_ baseUrl: URL) -> MessageServerBuilder {
            self.baseUrl = baseUrl
            return self
        }
        
        func path(_ path: String) -> MessageServerBuilder {
            self.path += "/" + path
            return self
        }
        
        func body(_ body: RequestParameter) -> MessageServerBuilder {
            self.body = body
            return self
        }
        
        func query(_ query: RequestParameter) -> MessageServerBuilder {
            self.query = query
            return self
        }
        
        func keyPath(_ keyPath: String) -> MessageServerBuilder {
            self.keyPath = keyPath
            return self
        }
        
        func queue(_ queue: DispatchQueue?) -> MessageServerBuilder {
            self.queue = queue
            return self
        }
    }
    
    class KmsServerBuilder{
        private static let apiBaseUrl: URL = URL(string: ServiceRequest.KMS_SERVER_ADDRESS)!
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
            self.baseUrl = KmsServerBuilder.apiBaseUrl
            self.method = .get
            self.path = ""
        }
        
        func build() -> ServiceRequest {
            return ServiceRequest(authenticator: authenticator, url: baseUrl.appendingPathComponent(path), headers: headers, method: method, body: body, query: query, keyPath: keyPath, queue: queue)
        }
        
        func method(_ method: Alamofire.HTTPMethod) -> KmsServerBuilder {
            self.method = method
            return self
        }
        
        func headers(_ headers: [String: String]) -> KmsServerBuilder {
            self.headers = headers
            return self
        }
        
        func baseUrl(_ baseUrl: String) -> KmsServerBuilder {
            self.baseUrl = URL(string: baseUrl)!
            return self
        }
        
        func baseUrl(_ baseUrl: URL) -> KmsServerBuilder {
            self.baseUrl = baseUrl
            return self
        }
        
        func path(_ path: String) -> KmsServerBuilder {
            self.path += "/" + path
            return self
        }
        
        func body(_ body: RequestParameter) -> KmsServerBuilder {
            self.body = body
            return self
        }
        
        func query(_ query: RequestParameter) -> KmsServerBuilder {
            self.query = query
            return self
        }
        
        func keyPath(_ keyPath: String) -> KmsServerBuilder {
            self.keyPath = keyPath
            return self
        }
        
        func queue(_ queue: DispatchQueue?) -> KmsServerBuilder {
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
            SessionManager.default.adapter = self
            SessionManager.default.retrier = self
            completionHandler(Alamofire.request(urlRequestConvertible).validate())
        }
        
        authenticator.accessToken { accessToken in
            accessTokenCallback(accessToken)
        }
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if let newToken = self.newAccessToken, let _ =  urlRequest.value(forHTTPHeaderField: "Authorization"){
            urlRequest.setValue("Bearer " + newToken, forHTTPHeaderField: "Authorization")
            self.refreshTokenCount += 1
        }
        return urlRequest
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion){
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 429 {
            if let retryAfter = response.allHeaderFields["Retry-After"] as? Int{
                var retryAfterInt: Int
                if retryAfter > 3600{
                    retryAfterInt = 3600
                }else if retryAfter == 0{
                    retryAfterInt = 60
                }else{
                    retryAfterInt = retryAfter
                }
                self.pendingTimeCount += retryAfterInt
                completion(true, TimeInterval(retryAfterInt))
            }
        }else if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            self.authenticator.refreshToken(completionHandler: { accessToken in
                if accessToken == nil{
                    self.newAccessToken = accessToken
                    completion(false, 0.0)
                }else{
                    if self.refreshTokenCount >= 2{// After Refreshed token twice, if still get 401 from server, returns error.
                        completion(false, 0.0)
                    }else{
                        self.newAccessToken = accessToken
                        completion(true, 0.0)
                    }
                }
            })
        }else{
            completion(false,0.0)
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

