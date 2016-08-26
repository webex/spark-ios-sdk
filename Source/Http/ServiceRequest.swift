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
    
    fileprivate var url: URLStringConvertible {
        return URL(string: baseUrl)!.appendingPathComponent(path)
    }
    
    fileprivate var headers: [String: String]
    fileprivate var method: Alamofire.HTTPMethod
    fileprivate var baseUrl: String
    fileprivate var path: String
    fileprivate var authRequired: Bool
    fileprivate var body: RequestParameter?
    fileprivate var query: RequestParameter?
    fileprivate var keyPath: String?
    fileprivate var queue: DispatchQueue?
    
    
    init() {
        let userAgent = UserAgent.sharedInstance.userAgentString
        self.headers = ["Content-Type": "application/json",
                        "User-Agent": userAgent!]
        
        self.authRequired = true
        self.baseUrl = "https://api.ciscospark.com/v1"
        self.method = .get
        self.path = ""
    }
    
    class Builder {
        fileprivate var request = ServiceRequest()
        
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
        let request = createAlamofireRequest()
        
        _ = request.responseObject(queue: queue, keyPath: keyPath) {
            (response: Response<T, NSError>) in
            var result: Result<T>
            
            switch response.result {
            case .success(let value):
                result = .success(value)
                
            case .failure(var error):
                if response.response != nil {
                    if let data = response.data {
                        error = Error.requestErrorWithData(data)
                    }
                }
                result = .failure(error)
            }
            
            completionHandler(ServiceResponse(response.response, result))
        }
    }
    
    func responseArray<T: Mappable>(_ completionHandler: @escaping (ServiceResponse<[T]>) -> Void){
        let request = createAlamofireRequest()
        
        _ = request.responseArray(queue: queue, keyPath: keyPath){
            (response: Response<[T], NSError>) in
            var result: Result<[T]>
            
            switch response.result {
            case .success(let value):
                result = .success(value)
                
            case .failure(var error):
                if response.response != nil {
                    if let data = response.data {
                        error = Error.requestErrorWithData(data)
                    }
                }
                result = .failure(error)
            }
            
            completionHandler(ServiceResponse(response.response, result))
        }
    }
    
    func responseJSON(_ completionHandler: @escaping (ServiceResponse<Any>) -> Void){
        let request = createAlamofireRequest()
        
        request.responseJSON(queue: queue){
            (response: Response<Any, NSError>) in
            var result: Result<Any>
            
            switch response.result {
            case .success(let value):
                result = .success(value)
                
            case .failure(var error):
                if response.response != nil {
                    if let data = response.data {
                        error = Error.requestErrorWithData(data)
                    }
                }
                result = .failure(error)
            }
            
            completionHandler(ServiceResponse(response.response, result))
        }
    }
    
	private func createAlamofireRequest() -> Alamofire.Request {
		if authRequired {
			if let authorization = AuthManager.sharedInstance.getAuthorization() {
				headers.unionInPlace(authorization)
			}
		}
		let parameters: [String:Any]?
		let encoding: ParameterEncoding
		if let body = body {
			parameters = body.value()
			encoding = .json
		} else if let query = query {
			parameters = query.value()
			encoding = .url
		} else {
			parameters = nil
			encoding = .url
		}
		
		return Alamofire.request(url, withMethod: method, parameters: parameters, encoding: encoding, headers: headers).validate()
	}

}

