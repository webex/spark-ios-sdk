// Copyright 2016-2017 Cisco Systems Inc
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

class SerialQueue {
    
    private let ops: OperationQueue
    
    private let queue: DispatchQueue
    
    var underlying: DispatchQueue {
        return self.queue
    }
    
    init(_ queue: DispatchQueue? = nil) {
        self.queue = queue ?? DispatchQueue(label: "com.cisoc.spark-ios-sdk.BaseSerialQueue-\(UUID().uuidString)")
        self.ops = OperationQueue()
        self.ops.underlyingQueue = self.queue
        self.ops.maxConcurrentOperationCount = 1
    }
    
    func sync(_ block: @escaping () -> Void) {
        self.ops.addOperation {
            self.ops.isSuspended = true
            self.queue.async {
                block()
            }
        }
    }
    
    func yield() {
        self.queue.async {
            self.ops.isSuspended = false
        }
    }
    
}
