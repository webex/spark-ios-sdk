// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
