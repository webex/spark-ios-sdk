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
    var accessTokenExpiration: NSTimeInterval?
    var refreshTokenString: String?
    var refreshTokenExpiration: NSTimeInterval?
    var accessTokenCreation: NSTimeInterval?
    
    var accessTokenExpirationDate: NSDate {
        return NSDate(timeInterval: accessTokenExpiration!, sinceDate: accessTokenCreationDate)
    }
    
    var accessTokenCreationDate: NSDate {
        return NSDate(timeIntervalSinceReferenceDate: accessTokenCreation!)
    }
    
    private let accessTokenKey = "accessTokenKey"
    private let accessTokenExpirationKey = "accessTokenExpirationKey"
    private let refreshTokenKey = "refreshTokenKey"
    private let refreshTokenExpirationKey = "refreshTokenExpirationKey"
    private let accessTokenCreationKey = "accessTokenCreationKey"
    
    init(accessToken: String) {
        self.accessTokenString = accessToken
    }
    
    // MARK:- Mappable
    
    required init?(_ map: Map) {
        accessTokenCreation = NSDate().timeIntervalSinceReferenceDate
    }
    
    func mapping(map: Map) {
        accessTokenString <- map["access_token"]
        accessTokenExpiration <- map["expires_in"]
        refreshTokenString <- map["refresh_token"]
        refreshTokenExpiration <- map["refresh_token_expires_in"]
    }
    
    // MARK:- NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        accessTokenString = aDecoder.decodeObjectForKey(accessTokenKey) as? String
        accessTokenExpiration = aDecoder.decodeDoubleForKey(accessTokenExpirationKey)
        refreshTokenString = aDecoder.decodeObjectForKey(refreshTokenKey) as? String
        refreshTokenExpiration = aDecoder.decodeDoubleForKey(refreshTokenExpirationKey)
        accessTokenCreation = aDecoder.decodeDoubleForKey(accessTokenCreationKey)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        encodeObject(accessTokenString, forKey: accessTokenKey, aCoder: aCoder)
        encodeDouble(accessTokenExpiration, forKey: accessTokenExpirationKey, aCoder: aCoder)
        encodeObject(refreshTokenString, forKey: refreshTokenKey, aCoder: aCoder)
        encodeDouble(refreshTokenExpiration, forKey: refreshTokenExpirationKey, aCoder: aCoder)
        encodeDouble(accessTokenCreation, forKey: accessTokenCreationKey, aCoder: aCoder)
    }
    
    private func encodeObject(objv: AnyObject?, forKey key: String, aCoder: NSCoder) {
        guard objv != nil else {
            return
        }
        
        aCoder.encodeObject(objv, forKey: key)
    }
    
    private func encodeDouble(realv: Double?, forKey key: String, aCoder: NSCoder) {
        guard let realValue = realv else {
            return
        }
        
        aCoder.encodeDouble(realValue, forKey: key)
    }
}