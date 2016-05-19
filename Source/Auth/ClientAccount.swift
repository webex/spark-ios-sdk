//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class ClientAccount: NSObject, NSCoding {
    var clientId: String
    var clientSecret: String
    
    private let clientIdKey = "clientIdKey"
    private let clientSecretKey = "clientSecretKey"
    
    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    required init?(coder aDecoder: NSCoder) {
        clientId = aDecoder.decodeObjectForKey(clientIdKey) as! String
        clientSecret = aDecoder.decodeObjectForKey(clientSecretKey) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(clientId, forKey: clientIdKey)
        aCoder.encodeObject(clientSecret, forKey: clientSecretKey)
    }
}