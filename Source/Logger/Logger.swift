// Copyright 2016-2018 Cisco Systems Inc
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

/// A protocol for logging in the SDK.
///
/// - since: 1.2.0
public protocol Logger {
    /// log a message.
    ///
    /// - parameter message: the mesage to be logged
    /// - returns: Void
    /// - since: 1.2.0
    func log(message: LogMessage)
}

/// Information about the log message.
///
/// - since: 1.2.0
public struct LogMessage {
    /// The log message.
    public let message: String
    /// The log level.
    public let level: LogLevel
    /// The source file where the log message is generated.
    public let file: String
    /// The function where the log message is generated.
    public let function: String
    /// The line where the log message is generated.
    public let line: UInt
    /// The description of the log message.
    public let description: String
    /// The date and time when the log message is generated.
    public let timestamp: Date
    /// The name of the thread where the log message is generated.
    public let threadName: String
}

/// The enumeration of log message level
///
/// - since: 1.2.0
public enum LogLevel: UInt {
    /// Turn off logging.
    case no
    /// This is an error message.
    case error
    /// This is a warning message.
    case warning
    /// This is an info message.
    case info
    /// This is a debug message.
    case debug
    /// This is a verbose message.
    case verbose
    /// Turn all all logging.
    case all
}
