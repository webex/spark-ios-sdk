//
//  SparkError.swift
//  SparkSDK
//
//  Created by zhiyuliu on 06/05/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

public enum SparkError: Error {
    
    case serviceFailed(code: Int, reason: String)
    case unregistered
    case requireH264
    case invalidDTMF
    case unsupportedDTMF
    case illegalOperation(reason: String)
    case illegalStatus(reason: String)
}
