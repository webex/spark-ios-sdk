//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

extension NSDate {
    func isAfterDate(date: NSDate) -> Bool {
        return self.compare(date) == .OrderedDescending
    }
}