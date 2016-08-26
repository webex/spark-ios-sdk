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

class OAuthClient: CompletionHandlerType<AccessToken> {
    
    fileprivate func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder()
            .path("access_token")
            .headers(["Content-Type": "application/x-www-form-urlencoded"])
            .authRequired(false)
    }
    
    // MARK:- Async API
    
    func fetchAccessTokenFromOAuthCode(_ code: String, _ clientAccount: ClientAccount, redirectUri: String, queue: DispatchQueue? = nil, completionHandler: ObjectHandler) {
        let query = RequestParameter(["grant_type": "authorization_code",
            "redirect_uri": redirectUri,
            "code": code,
            "client_id": clientAccount.clientId,
            "client_secret": clientAccount.clientSecret])
        
        let request = requestBuilder()
            .method(.post)
            .query(query)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func refreshOAuthAccessTokenFromRefreshToken(_ refreshToken: String, _ clientAccount: ClientAccount, queue: DispatchQueue? = nil, completionHandler: ObjectHandler) {
        let query = RequestParameter(["grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientAccount.clientId,
            "client_secret": clientAccount.clientSecret])
        
        let request = requestBuilder()
            .method(.post)
            .query(query)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    // MARK:- Sync API
    
    func fetchAccessTokenFromOAuthCode(_ code: String, clientAccount: ClientAccount, redirectUri: String) throws -> AccessToken {
		return try SyncUtil.getObject(code, clientAccount, redirectUri, async: fetchAccessTokenFromOAuthCode)
    }
    
    func refreshAccessTokenFromRefreshToken(_ refreshToken: String, clientAccount: ClientAccount) throws -> AccessToken {
        return try SyncUtil.getObject(refreshToken, clientAccount, async: refreshOAuthAccessTokenFromRefreshToken)
    }
}
