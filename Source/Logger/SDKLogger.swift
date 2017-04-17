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

class SDKLogger {
    
    static let defaultLevel = DDLogLevel.info
    
    static func verbose(_ message: @autoclosure () -> String, error: Error? = nil, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.verbose, file: file, function: function, line: line)
    }
    
    static func debug(_ message: @autoclosure () -> String, error: Error? = nil, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.debug, file: file, function: function, line: line)
    }
    
    static func info(_ message: @autoclosure () -> String, error: Error? = nil, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.info, file: file, function: function, line: line)
    }
    
    static func warn(_ message: @autoclosure () -> String, error: Error? = nil, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.warning, file: file, function: function, line: line)
    }
    
	static func error(_ message: @autoclosure () -> String, error: Error? = nil, level: DDLogLevel = defaultLevel, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), level: level, flag: DDLogFlag.error, file: file, function: function, line: line, asynchronous: false)
    }
    
    static private func log(_ message: @autoclosure () -> String, error: Error? = nil, level: DDLogLevel, flag: DDLogFlag, context: Int = 0, file: String, function: String, line: UInt, tag: Any? = nil, asynchronous: Bool = true, ddlog: DDLog = DDLog.sharedInstance()) {
        guard LoggerManager.sharedInstance.hasSetup() else {
            return
        }

        if level.rawValue & flag.rawValue != 0 {
			let actualMessage: String
			if let error = error as NSError? {
				actualMessage = "\(message()): \(String(describing: error.localizedFailureReason))"
			} else {
				actualMessage = message()
			}
            let logMessage = DDLogMessage(message: actualMessage, level: level, flag: flag, context: context, file: file, function: function, line: line, tag: tag, options: [.copyFile, .copyFunction], timestamp: nil)
            ddlog.log(asynchronous: asynchronous, message: logMessage)
        }
    }
}
