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
    
    static func getObject<T>(_ authenticationStrategy: AuthenticationStrategy, _ async: @escaping (_ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(authenticationStrategy, async)())
    }
    
    static func getObject<I, T>(_ authenticationStrategy: AuthenticationStrategy, _ i: I, async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(authenticationStrategy, async)(i))
    }

    static func getObject<I0, I1, T>(_ authenticationStrategy: AuthenticationStrategy, _ i0: I0, _ i1: I1, async: @escaping (I0, I1, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(authenticationStrategy, async)(i0, i1))
    }

    static func getObject<I0, I1, I2, T>(_ authenticationStrategy: AuthenticationStrategy, _ i0: I0, _ i1: I1, _ i2: I2, async: @escaping (I0, I1, I2, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(authenticationStrategy, async)(i0, i1, i2))
    }
    
    static func getObject<I0, I1, I2, I3, T>(_ authenticationStrategy: AuthenticationStrategy, _ i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, async: @escaping (I0, I1, I2, I3, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(authenticationStrategy, async)(i0, i1, i2, i3))
    }
    
    static func getObject<I0, I1, I2, I3, I4, T>(_ authenticationStrategy: AuthenticationStrategy, _ i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, _ i4: I4, async: @escaping (I0, I1, I2, I3, I4, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws -> T {
        return try getObject(sync(authenticationStrategy, async)(i0, i1, i2, i3, i4))
    }
    
    static func getArray<I, T>(_ authenticationStrategy: AuthenticationStrategy, _ i: I, async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(authenticationStrategy, async)(i))
    }
    
    static func getArray<I0, I1, T>(_ authenticationStrategy: AuthenticationStrategy, _ i0: I0, _ i1: I1, async: @escaping (I0, I1, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(authenticationStrategy, async)(i0, i1))
    }
    
    static func getArray<I0, I1, I2, T>(_ authenticationStrategy: AuthenticationStrategy, _ i0: I0, _ i1: I1, _ i2: I2, async: @escaping (I0, I1, I2, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(authenticationStrategy, async)(i0, i1, i2))
    }
    
    static func getArray<I0, I1, I2, I3, T>(_ authenticationStrategy: AuthenticationStrategy, _ i0: I0, _ i1: I1, _ i2: I2, _ i3: I3, async: @escaping (I0, I1, I2, I3, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<[T]>) -> Void) -> Void) throws -> [T] {
        return try getArray(sync(authenticationStrategy, async)(i0, i1, i2, i3))
    }
    
    static func deleteObject<I, T>(_ authenticationStrategy: AuthenticationStrategy, _ i: I, async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (ServiceResponse<T>) -> Void) -> Void) throws {
        try _ = getObject(sync(authenticationStrategy, async)(i))
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
        
    private static func sync<I, T>(_ authenticationStrategy: AuthenticationStrategy, _ async: @escaping (I, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) throws -> (I) -> T {
        if Thread.current.isMainThread {
            Logger.warn("Synchronous network calls detected on the main thread. This is not safe and may result in instability.")
            var accessTokenCallCanCompleteImmediately = false
            authenticationStrategy.accessToken() { _ in
                accessTokenCallCanCompleteImmediately = true
            }
            guard accessTokenCallCanCompleteImmediately else {
                Logger.error("Synchronous network call made on the main thread before Spark had obtained an access token. This should be avoided by switching to asynchronous network call methods")
                throw NSError(domain: "com.cisco.SparkSDK", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "Synchronous network call made on the main thread before Spark had obtained an access token"])
            }
        }
        
        return { i in
            let semaphore = DispatchSemaphore(value: 0)
            let queue = DispatchQueue.global()
            
            var t: T?
            async(i, queue) {
                t = $0
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            return t!
        }
    }
    
    private static func sync<T>(_ authenticationStrategy: AuthenticationStrategy, _ async: @escaping (_ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) throws -> (Void) -> T {
        return try sync(authenticationStrategy, {async($1, $2)})
    }
    
    private static func sync<I0, I1, T>(_ authenticationStrategy: AuthenticationStrategy, _ async: @escaping (I0, I1, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) throws -> (I0, I1) -> T {
        return try sync(authenticationStrategy, {async($0.0, $0.1, $1, $2)})
    }
    
    private static func sync<I0, I1, I2, T>(_ authenticationStrategy: AuthenticationStrategy, _ async: @escaping (I0, I1, I2, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) throws -> (I0, I1, I2) -> T {
        return try sync(authenticationStrategy, {async($0.0, $0.1, $0.2, $1, $2)})
    }
    
    private static func sync<I0, I1, I2, I3, T>(_ authenticationStrategy: AuthenticationStrategy, _ async: @escaping (I0, I1, I2, I3, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) throws -> (I0, I1, I2, I3) -> T {
        return try sync(authenticationStrategy, {async($0.0, $0.1, $0.2, $0.3, $1, $2)})
    }
    
    private static func sync<I0, I1, I2, I3, I4, T>(_ authenticationStrategy: AuthenticationStrategy, _ async: @escaping (I0, I1, I2, I3, I4, _ queue: Queue?, _ completionHandler: @escaping (T) -> Void) -> Void) throws -> (I0, I1, I2, I3, I4) -> T {
        return try sync(authenticationStrategy, {async($0.0, $0.1, $0.2, $0.3, $0.4, $1, $2)})
    }
}
