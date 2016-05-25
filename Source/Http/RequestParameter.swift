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