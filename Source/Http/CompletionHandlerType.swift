//
//  CompletionHandler.swift
//  Pods
//
//  Created by bxu3 on 5/4/16.
//
//

import Foundation
import Alamofire

public class CompletionHandlerType<T> {
    public typealias ObjectHandler = ServiceResponse<T> -> Void
    public typealias ArrayHandler = ServiceResponse<[T]> -> Void
    public typealias AnyObjectHandler = ServiceResponse<AnyObject> -> Void
}