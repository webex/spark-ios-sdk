//
//  Response.swift
//  Pods
//
//  Created by bxu3 on 5/4/16.
//
//

import Foundation

public enum Result<T> {
    case Success(T)
    case Failure(NSError)
}