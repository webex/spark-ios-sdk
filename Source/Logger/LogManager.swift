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
