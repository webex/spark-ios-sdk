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
import CocoaLumberjack

class Logger {
    
    static let defaultLevel = DDLogLevel.Info
    
    static func verbose(@autoclosure message: () -> String, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.Verbose, file: file, function: function, line: line)
    }
    
    static func debug(@autoclosure message: () -> String, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.Debug, file: file, function: function, line: line)
    }
    
    static func info(@autoclosure message: () -> String, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.Info, file: file, function: function, line: line)
    }
    
    static func warn(@autoclosure message: () -> String, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.Warning, file: file, function: function, line: line)
    }
    
    static func error(@autoclosure message: () -> String, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.Error, file: file, function: function, line: line, asynchronous: false)
    }
    
    static private func log(@autoclosure message: () -> String, level: DDLogLevel, flag: DDLogFlag, context: Int = 0, file: String, function: String, line: UInt, tag: AnyObject? = nil, asynchronous: Bool = true, ddlog: DDLog = DDLog.sharedInstance()) {
        guard LoggerManager.sharedInstance.hasSetup() else {
            return
        }

        if level.rawValue & flag.rawValue != 0 {
            let logMessage = DDLogMessage(message: message(), level: level, flag: flag, context: context, file: file, function: function, line: line, tag: tag, options: [.CopyFile, .CopyFunction], timestamp: nil)
            ddlog.log(asynchronous, message: logMessage)
        }
    }
}
