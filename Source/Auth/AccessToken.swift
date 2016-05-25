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