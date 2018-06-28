// Copyright 2016-2018 Cisco Systems Inc
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
import Wme

class InterfaceAddress {
    
    typealias Item = (ifaName: String, ifaAddr: String)

    static func getSortedAddresses() -> [Item] {
        var addresses = [Item]()
        if let hostAddr = NetUtils.getHostAddresses() {
            for element in hostAddr {
                addresses.append((ifaName: element.ifaName, ifaAddr: element.ifaAddr))
            }

            return addresses.sorted{$0.ifaName+$0.ifaAddr < $1.ifaName+$1.ifaAddr}
        } else {
            return []
        }
    }
    
    static func isSameSortedAddresses(oldAddrs: [Item], newAddrs: [Item]) -> Bool {
        if oldAddrs.count != newAddrs.count {
            return false
        }
        
        for i in 0..<oldAddrs.count {
            if !isSameAddress(oldAddr: oldAddrs[i], newAddr: newAddrs[i]) {
                return false
            }
        }
        
        return true
    }
    
    private static func isSameAddress(oldAddr: Item, newAddr: Item) -> Bool {
        return oldAddr.ifaName == newAddr.ifaName && oldAddr.ifaAddr == newAddr.ifaAddr
    }
}
