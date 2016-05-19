//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension NSURL {
    var queryParameters: [String: String] {
        var queryParameters = [String: String]()
        let pairs  = self.query?.componentsSeparatedByString("&") ?? []
        
        for pair in pairs {
            let kv = pair.componentsSeparatedByString("=")
            queryParameters.updateValue(kv[1], forKey: kv[0])
        }
        
        return queryParameters
    }
}