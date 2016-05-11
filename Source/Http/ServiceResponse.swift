//
//  Response.swift
//  Pods
//
//  Created by bxu3 on 5/5/16.
//
//

import Foundation

public struct ServiceResponse<T> {
    public let response: NSHTTPURLResponse?
    public let result: Result<T>
    
    public init(_ response: NSHTTPURLResponse?, _ result: Result<T>) {
        self.response = response
        self.result = result
    }
}