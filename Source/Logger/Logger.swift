//
//  Logger.swift
//  SparkSDK
//
//  Created by zhiyuliu on 28/03/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

public protocol Logger {
    func log(message: LogMessage)
}

public struct LogMessage {
    public let message: String
    public let level: LogLevel
    public let file: String
    public let function: String
    public let line: UInt
    public let description: String
}

public enum LogLevel: Int {
    case error
    case warning
    case info
    case debug
    case verbose
}
