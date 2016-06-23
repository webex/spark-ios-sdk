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
import Wme

class InterfaceAddress {
    
    typealias Item = (ifaName: String, ifaAddr: String)

    static func getSortedAddresses() -> [Item] {
        var addresses = [Item]()
        let hostAddr = Wme.NetUtils.getHostAddresses()
        for element in hostAddr {
            addresses.append((ifaName: element.ifaName, ifaAddr: element.ifaAddr))
        }
        
        return addresses.sort{$0.ifaName+$0.ifaAddr < $1.ifaName+$1.ifaAddr}
    }
    
    static func isSameSortedAddresses(oldAddrs oldAddrs: [Item], newAddrs: [Item]) -> Bool {
        if oldAddrs.count != newAddrs.count {
            return false
        }
        
        for i in 0..<oldAddrs.count {
            if !isSameAddress(oldAddr: oldAddrs[i], newAddr: newAddrs[i]) {
                Logger.info("Address changed: \(oldAddrs[i]) -> \(newAddrs[i])")
                return false
            }
        }
        
        return true
    }
    
    private static func isSameAddress(oldAddr oldAddr: Item, newAddr: Item) -> Bool {
        return oldAddr.ifaName == newAddr.ifaName && oldAddr.ifaAddr == newAddr.ifaAddr
    }
}
