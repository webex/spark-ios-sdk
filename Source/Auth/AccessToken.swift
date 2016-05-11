//
//  AccessToken.swift
//  SparkSDK
//
//  Created by xiuwenwu on 16/2/23.
//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

// TODO:  ublic or not
public class AccessToken: NSObject, NSCoding, Mappable {
    
    public var accessTokenString: String?
    public var accessTokenExpiration: NSTimeInterval?
    public var refreshTokenString: String?
    public var refreshTokenExpiration: NSTimeInterval?
    
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
    
    required public init?(_ map: Map) {
    }
    
    public required init?(coder aDecoder: NSCoder) {
        accessTokenString = aDecoder.decodeObjectForKey(accessTokenKey) as? String
        accessTokenExpiration = aDecoder.decodeDoubleForKey(accessTokenExpirationKey)
        refreshTokenString = aDecoder.decodeObjectForKey(refreshTokenKey) as? String
        refreshTokenExpiration = aDecoder.decodeDoubleForKey(refreshTokenExpirationKey)
    }
    
    public func mapping(map: Map) {
        accessTokenString <- map["access_token"]
        accessTokenExpiration <- map["expires_in"]
        refreshTokenString <- map["refresh_token"]
        refreshTokenExpiration <- map["refresh_token_expires_in"]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(accessTokenString, forKey: accessTokenKey)
        aCoder.encodeDouble(accessTokenExpiration!, forKey: accessTokenExpirationKey)
        aCoder.encodeObject(refreshTokenString, forKey: refreshTokenKey)
        aCoder.encodeDouble(refreshTokenExpiration!, forKey: refreshTokenExpirationKey)
    }
}