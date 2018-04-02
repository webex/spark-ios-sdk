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

class JWTTokenModel: NSObject, Mappable {
    
    var token: String?
    var tokenExpiration: TimeInterval?
    var tokenCreationDate: Date
    
    var tokenExpirationDate: Date {
        return Date(timeInterval: tokenExpiration!, since: tokenCreationDate)
    }
    
    init(token: String) {
        self.token = token
        tokenCreationDate = Date()
    }
    
    // MARK:- Mappable
    
    required init?(map: Map) {
        tokenCreationDate = Date()
    }
    func mapping(map: Map) {
        token <- map["token"]
        tokenExpiration <- map["expiresIn"]
    }
}


class JWTAuthClient {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(SimpleAuthStrategy.neverAuthorized())
            .path("jwt/login")
    }
    
    func fetchTokenFromJWT(_ jwt: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<JWTTokenModel>) -> Void) {
        let request = requestBuilder()
            .method(.post)
            .headers(["Authorization": jwt,
                      "Content-Type": "text/plain",
                      "Cache-Control": "no-cache",
                      "Accept-Encoding": "none"])
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func refreshTokenFromJWT(_ jwt: String, queue: DispatchQueue? = nil, completionHandler: @escaping (ServiceResponse<JWTTokenModel>) -> Void){
        self.fetchTokenFromJWT(jwt, queue: queue, completionHandler: completionHandler)
    }
}
