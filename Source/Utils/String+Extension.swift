//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension String {
    var decodeString: String? {
        return self.stringByReplacingOccurrencesOfString("+", withString: " ").stringByRemovingPercentEncoding
    }
    
    var encodeString: String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
    }
}