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

struct SyncUtil {
    typealias Queue = dispatch_queue_t
    
    // MARK: - generic API to synchronize async API, and then parse result
    
    static func getObject<T>(async: (queue: Queue?, completionHandler: ServiceResponse<T> -> Void) -> Void) throws -> T {
        return try getObject(sync(async)())
    }
    
    static func getObject<I, T>(i: I, async: (I, queue: Queue?, completionHandler: ServiceResponse<T> -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i))
    }
    
    static func getObject<I0, I1, T>(i0: I0, _ i1: I1, async: (I0, I1, queue: Queue?, completionHandler: ServiceResponse<T> -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1))
    }
    
    static func getObject<I0, I1, I2, T>(i0: I0, _ i1: I1, _ i2: I2, async: (I0, I1, I2, queue: Queue?, completionHandler: ServiceResponse<T> -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1, i2))
    }
    
    static func getObject<I0, I1, I2, I3, T>(i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, async: (I0, I1, I2, I3, queue: Queue?, completionHandler: ServiceResponse<T> -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1, i2, i3))
    }
    
    static func getObject<I0, I1, I2, I3, I4, T>(i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, _ i4: I4, async: (I0, I1, I2, I3, I4, queue: Queue?, completionHandler: ServiceResponse<T> -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1, i2, i3, i4))
    }
    
    static func getArray<I, T>(i: I, async: (I, queue: Queue?, completionHandler: ServiceResponse<[T]> -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i))
    }
    
    static func getArray<I0, I1, T>(i0: I0, _ i1: I1, async: (I0, I1, queue: Queue?, completionHandler: ServiceResponse<[T]> -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i0, i1))
    }
    
    static func getArray<I0, I1, I2, T>(i0: I0, _ i1: I1, _ i2: I2, async: (I0, I1, I2, queue: Queue?, completionHandler: ServiceResponse<[T]> -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i0, i1, i2))
    }
    
    static func getArray<I0, I1, I2, I3, T>(i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, async: (I0, I1, I2, I3, queue: Queue?, completionHandler: ServiceResponse<[T]> -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i0, i1, i2, i3))
    }
    
    static func deleteObject<I, T>(i: I, async: (I, queue: Queue?, completionHandler: ServiceResponse<T> -> Void) -> Void) throws {
        try getObject(sync(async)(i))
    }
    
    private static func getObject<T>(response: ServiceResponse<T>) throws -> T {
        var t: T
        switch response.result {
        case .Success(let value):
            t = value
        case .Failure(let error):
            throw error
        }
        return t
    }
    
    private static func getArray<T>(response: ServiceResponse<[T]>) throws -> [T] {
        var t: [T]
        switch response.result {
        case .Success(let value):
            t = value
        case .Failure(let error):
            throw error
        }
        return t
    }
    
    // MARK: - generic API to transform async to sync
        
    private static func sync<I, T>(async: (I, queue: Queue?, completionHandler: T -> Void) -> Void) -> I -> T {
        return { i in
            let semaphore = dispatch_semaphore_create(0)
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            var t: T!
            async(i, queue: queue) {
                t = $0
                dispatch_semaphore_signal(semaphore)
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            return t
        }
    }
    
    private static func sync<T>(async: (queue: Queue?, completionHandler: T -> Void) -> Void) -> Void -> T {
        return sync({async(queue: $1, completionHandler: $2)})
    }
    
    private static func sync<I0, I1, T>(async: (I0, I1, queue: Queue?, completionHandler: T -> Void) -> Void) -> (I0, I1) -> T {
        return sync({async($0.0, $0.1, queue: $1, completionHandler: $2)})
    }
    
    private static func sync<I0, I1, I2, T>(async: (I0, I1, I2, queue: Queue?, completionHandler: T -> Void) -> Void) -> (I0, I1, I2) -> T {
        return sync({async($0.0, $0.1, $0.2, queue: $1, completionHandler: $2)})
    }
    
    private static func sync<I0, I1, I2, I3, T>(async: (I0, I1, I2, I3, queue: Queue?, completionHandler: T -> Void) -> Void) -> (I0, I1, I2, I3) -> T {
        return sync({async($0.0, $0.1, $0.2, $0.3, queue: $1, completionHandler: $2)})
    }
    
    private static func sync<I0, I1, I2, I3, I4, T>(async: (I0, I1, I2, I3, I4, queue: Queue?, completionHandler: T -> Void) -> Void) -> (I0, I1, I2, I3, I4) -> T {
        return sync({async($0.0, $0.1, $0.2, $0.3, $0.4, queue: $1, completionHandler: $2)})
    }
}
