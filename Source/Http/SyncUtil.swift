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
    typealias Queue = DispatchQueue
    
    // MARK: - generic API to synchronize async API, and then parse result
    
    static func getObject<T>(_ async: @escaping (_ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(async)())
    }
    
    static func getObject<I, T>(_ i: I, async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i))
    }

    static func getObject<I0, I1, T>(_ i0: I0, _ i1: I1, async: @escaping (I0, I1, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1))
    }

    static func getObject<I0, I1, I2, T>(_ i0: I0, _ i1: I1, _ i2: I2, async: @escaping (I0, I1, I2, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1, i2))
    }
    
    static func getObject<I0, I1, I2, I3, T>(_ i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, async: @escaping (I0, I1, I2, I3, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1, i2, i3))
    }
    
    static func getObject<I0, I1, I2, I3, I4, T>(_ i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, _ i4: I4, async: @escaping (I0, I1, I2, I3, I4, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(async)(i0, i1, i2, i3, i4))
    }
    
    static func getArray<I, T>(_ i: I, async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i))
    }
    
    static func getArray<I0, I1, T>(_ i0: I0, _ i1: I1, async: @escaping (I0, I1, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i0, i1))
    }
    
    static func getArray<I0, I1, I2, T>(_ i0: I0, _ i1: I1, _ i2: I2, async: @escaping (I0, I1, I2, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i0, i1, i2))
    }
    
    static func getArray<I0, I1, I2, I3, T>(_ i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, async: @escaping (I0, I1, I2, I3, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(async)(i0, i1, i2, i3))
    }
    
    static func deleteObject<I, T>(_ i: I, async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws {
        try _ = getObject(sync(async)(i))
    }
    
    private static func getObject<T>(_ response: ServiceResponse<T>) throws -> T {
        var t: T
        switch response.result {
        case .success(let value):
            t = value
        case .failure(let error):
            throw error
        }
        return t
    }
    
    private static func getArray<T>(_ response: ServiceResponse<[T]>) throws -> [T] {
        var t: [T]
        switch response.result {
        case .success(let value):
            t = value
        case .failure(let error):
            throw error
        }
        return t
    }
    
    // MARK: - generic API to transform async to sync
        
    private static func sync<I, T>(_ async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) -> (I) -> T {
        return { i in
            let semaphore = DispatchSemaphore(value: 0)
            let queue = DispatchQueue.global()
            
            var t: T!
            async(i, queue) {
                t = $0
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            return t
        }
    }
    
    private static func sync<T>(_ async: @escaping (_ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) -> (Void) -> T {
        return sync({async($1, $2)})
    }
    
    private static func sync<I0, I1, T>(_ async: @escaping (I0, I1, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) -> (I0, I1) -> T {
        return sync({async($0.0, $0.1, $1, $2)})
    }
    
    private static func sync<I0, I1, I2, T>(_ async: @escaping (I0, I1, I2, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) -> (I0, I1, I2) -> T {
        return sync({async($0.0, $0.1, $0.2, $1, $2)})
    }
    
    private static func sync<I0, I1, I2, I3, T>(_ async: @escaping (I0, I1, I2, I3, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) -> (I0, I1, I2, I3) -> T {
        return sync({async($0.0, $0.1, $0.2, $0.3, $1, $2)})
    }
    
    private static func sync<I0, I1, I2, I3, I4, T>(_ async: @escaping (I0, I1, I2, I3, I4, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) -> (I0, I1, I2, I3, I4) -> T {
        return sync({async($0.0, $0.1, $0.2, $0.3, $0.4, $1, $2)})
    }
}
