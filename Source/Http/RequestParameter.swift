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

struct RequestParameter {
    private var storage: [String: AnyObject] = [:]
    
    init(_ parameters: [String: Any?] = [:]) {
        for (key, value) in parameters {
            if value == nil {
                continue
            }
            
            switch value {
            case let bool as Bool:
                storage.updateValue(String(bool), forKey: key)
            case let anyObject as AnyObject:
                storage.updateValue(anyObject, forKey: key)
            default:
                break
            }
        }
    }
    
    func value() -> [String: AnyObject] {
        return storage
    }
    
    mutating func updateValue(value: AnyObject, forKey key: String) {
        storage.updateValue(value, forKey: key)
    }
}