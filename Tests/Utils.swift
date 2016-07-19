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

class Utils {
    
    static func waitBefore(interval: NSTimeInterval, closure: () -> Void) {
        NSThread.sleepForTimeInterval(interval)
        closure()
    }
    
    static func waitAfter(interval: NSTimeInterval, closure: () -> Void) {
        closure()
        NSThread.sleepForTimeInterval(interval)
    }
    
    static func wait(interval: NSTimeInterval) {
        NSThread.sleepForTimeInterval(interval)
    }
}