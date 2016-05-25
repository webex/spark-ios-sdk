// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

class OAuthClient: CompletionHandlerType<AccessToken> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder()
            .path("access_token")
            .headers(["Content-Type": "application/x-www-form-urlencoded"])
            .authRequired(false)
    }
    
    // MARK:- Async API
    
    func fetchAccessTokenFromOAuthCode(code: String, clientAccount: ClientAccount, redirectUri: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let query = RequestParameter(["grant_type": "authorization_code",
            "redirect_uri": redirectUri,
            "code": code,
            "client_id": clientAccount.clientId,
            "client_secret": clientAccount.clientSecret])
        
        let request = requestBuilder()
            .method(.POST)
            .query(query)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    func refreshOAuthAccessTokenFromRefreshToken(refreshToken: String, clientAccount: ClientAccount, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let query = RequestParameter(["grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientAccount.clientId,
            "client_secret": clientAccount.clientSecret])
        
        let request = requestBuilder()
            .method(.POST)
            .query(query)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    // MARK:- Sync API
    
    func fetchAccessTokenFromOAuthCode(code: String, clientAccount: ClientAccount, redirectUri: String) throws -> AccessToken {
        return try SyncUtil.getObject(code, clientAccount, redirectUri, async: fetchAccessTokenFromOAuthCode)
    }
    
    func refreshAccessTokenFromRefreshToken(refreshToken: String, clientAccount: ClientAccount) throws -> AccessToken {
        return try SyncUtil.getObject(refreshToken, clientAccount, async: refreshOAuthAccessTokenFromRefreshToken)
    }
}