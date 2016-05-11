//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

class AccessToken: NSObject, NSCoding, Mappable {
    
    var accessTokenString: String?
    var accessTokenExpiration: NSTimeInterval?
    var refreshTokenString: String?
    var refreshTokenExpiration: NSTimeInterval?
    
    private let accessTokenKey = "accessToken"
    private let accessTokenExpirationKey = "accessTokenExpiration"
    private let refreshTokenKey = "refreshToken"
    private let refreshTokenExpirationKey = "refreshTokenExpiration"
    
    init(accessToken: String) {
        self.accessTokenString = accessToken
        self.accessTokenExpiration = nil
        self.refreshTokenString = nil
        self.refreshTokenExpiration = nil
    }
    
    required init?(_ map: Map) {
    }
    
    required init?(coder aDecoder: NSCoder) {
        accessTokenString = aDecoder.decodeObjectForKey(accessTokenKey) as? String
        accessTokenExpiration = aDecoder.decodeDoubleForKey(accessTokenExpirationKey)
        refreshTokenString = aDecoder.decodeObjectForKey(refreshTokenKey) as? String
        refreshTokenExpiration = aDecoder.decodeDoubleForKey(refreshTokenExpirationKey)
    }
    
    func mapping(map: Map) {
        accessTokenString <- map["access_token"]
        accessTokenExpiration <- map["expires_in"]
        refreshTokenString <- map["refresh_token"]
        refreshTokenExpiration <- map["refresh_token_expires_in"]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(accessTokenString, forKey: accessTokenKey)
        aCoder.encodeDouble(accessTokenExpiration!, forKey: accessTokenExpirationKey)
        aCoder.encodeObject(refreshTokenString, forKey: refreshTokenKey)
        aCoder.encodeDouble(refreshTokenExpiration!, forKey: refreshTokenExpirationKey)
    }
}