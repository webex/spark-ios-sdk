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
import ObjectMapper

class AccessToken: NSObject, NSCoding, Mappable {
    
    var accessTokenString: String?
    var accessTokenExpiration: TimeInterval?
    var refreshTokenString: String?
    var refreshTokenExpiration: TimeInterval?
    var accessTokenCreationDate: Date
    
    var accessTokenExpirationDate: Date {
        return Date(timeInterval: accessTokenExpiration!, since: accessTokenCreationDate)
    }
    
    private let accessTokenKey = "accessTokenKey"
    private let accessTokenExpirationKey = "accessTokenExpirationKey"
    private let refreshTokenKey = "refreshTokenKey"
    private let refreshTokenExpirationKey = "refreshTokenExpirationKey"
    private let accessTokenCreationKey = "accessTokenCreationKey"
    
    init(accessToken: String) {
        accessTokenCreationDate = Date()
        accessTokenString = accessToken
    }
    
    // MARK:- Mappable
    
    required init?(map: Map) {
        accessTokenCreationDate = Date()
    }
    
    func mapping(map: Map) {
        accessTokenString <- map["access_token"]
        accessTokenExpiration <- map["expires_in"]
        refreshTokenString <- map["refresh_token"]
        refreshTokenExpiration <- map["refresh_token_expires_in"]
    }
    
    // MARK:- NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        accessTokenString = aDecoder.decodeObject(forKey: accessTokenKey) as? String
        accessTokenExpiration = aDecoder.decodeDouble(forKey: accessTokenExpirationKey)
        refreshTokenString = aDecoder.decodeObject(forKey: refreshTokenKey) as? String
        refreshTokenExpiration = aDecoder.decodeDouble(forKey: refreshTokenExpirationKey)
        accessTokenCreationDate = Date(timeIntervalSinceReferenceDate:aDecoder.decodeDouble(forKey: accessTokenCreationKey))
    }
    
    func encode(with aCoder: NSCoder) {
        encodeObject(accessTokenString, forKey: accessTokenKey, aCoder: aCoder)
        encodeDouble(accessTokenExpiration, forKey: accessTokenExpirationKey, aCoder: aCoder)
        encodeObject(refreshTokenString, forKey: refreshTokenKey, aCoder: aCoder)
        encodeDouble(refreshTokenExpiration, forKey: refreshTokenExpirationKey, aCoder: aCoder)
        encodeDouble(accessTokenCreationDate.timeIntervalSinceReferenceDate, forKey: accessTokenCreationKey, aCoder: aCoder)
    }
    
    private func encodeObject(_ objv: Any?, forKey key: String, aCoder: NSCoder) {
        guard objv != nil else {
            return
        }
        
        aCoder.encode(objv, forKey: key)
    }
    
    private func encodeDouble(_ realv: Double?, forKey key: String, aCoder: NSCoder) {
        guard let realValue = realv else {
            return
        }
        
        aCoder.encode(realValue, forKey: key)
    }
}
