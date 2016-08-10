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
import CocoaLumberjack.DDDispatchQueueLogFormatter

class LogFormatter : DDDispatchQueueLogFormatter {
    
    override func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        let timestamp: String = stringFromDate(logMessage.timestamp)
        let queueThreadLabel: String = queueThreadLabelForLogMessage(logMessage)

        var level: String
        switch (logMessage.flag) {
        case DDLogFlag.Error:   level = "E"
        case DDLogFlag.Warning: level = "W"
        case DDLogFlag.Info:    level = "I"
        case DDLogFlag.Debug:   level = "D"
        case DDLogFlag.Verbose: level = "V"
        default:                level = "V"
        }
        
        return level + " " + timestamp + " " + "[" + queueThreadLabel + "]" + " | " + logMessage.function + ": " + logMessage.message
    }
}

class LoggerManager {
    
    static let sharedInstance = LoggerManager()
    var isConsoleLoggerAdded: Bool
    let consoleLogger: DDTTYLogger
    let memoryLogger: MemoryLogger
    
    init() {
        // Console logger is added by default
        consoleLogger = DDTTYLogger()
        consoleLogger.logFormatter = LogFormatter()
        DDLog.addLogger(consoleLogger)
        isConsoleLoggerAdded = true
        
        // Always add memory logger
        memoryLogger = MemoryLogger()
        memoryLogger.logFormatter = LogFormatter()
        DDLog.addLogger(memoryLogger)
    }
    
    func hasSetup() -> Bool {
        return true
    }
    
    func toggleConsoleLogger(enable: Bool) {
        if isConsoleLoggerAdded && !enable {
            DDLog.removeLogger(consoleLogger)
        } else if !isConsoleLoggerAdded && enable {
            DDLog.addLogger(consoleLogger)
        }
    }
    
    func getMemoryLogs() -> String {
        return memoryLogger.getLogs()
    }
}
