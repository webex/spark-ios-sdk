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

/// A protocol for logging in the SDK.
///
/// - since: 1.2.0
public protocol Logger {
    func log(message: LogMessage)
}

/// Information about the log message.
///
/// - since: 1.2.0
public struct LogMessage {
    public let message: String
    public let level: LogLevel
    public let file: String
    public let function: String
    public let line: UInt
    public let description: String
    public let timestamp: Date
    public let threadName: String
}

/// The enumeration of log message level
///
/// - since: 1.2.0
public enum LogLevel: UInt {
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
}
