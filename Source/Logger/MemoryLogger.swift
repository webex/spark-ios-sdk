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

class MemoryLoggerStorage {

    // configs
    private let BlockSize = 10*1024
    private let BlockCount = 10

    // storage
    private var blocks: [String]
    private var blockIndex = 0
    
    init() {
        blocks = [String](count: BlockCount, repeatedValue: "")
    }
    
    func write(message: String) {
        objc_sync_enter(self)
        blocks[blockIndex] += message + "\n"
        if blocks[blockIndex].characters.count > BlockSize {
            blockIndex = (blockIndex + 1) % BlockCount
            blocks[blockIndex] = ""
        }
        objc_sync_exit(self)
    }
    
    func read() -> String {
        var output = ""
        objc_sync_enter(self)
        for offset in 1...BlockCount {
            output += blocks[(blockIndex + offset) % BlockCount]
        }
        objc_sync_exit(self)
        return output
    }
}

class MemoryLogger : DDAbstractLogger {

    private let storage = MemoryLoggerStorage()
    private var internalLogFormatter: DDLogFormatter?
    
    // workaround for log formatter.
    // see: https://github.com/CocoaLumberjack/CocoaLumberjack/issues/643
    override internal var logFormatter: DDLogFormatter! {
        set {
            super.logFormatter = newValue
            internalLogFormatter = newValue
        }
        get {
            return super.logFormatter
        }
    }

    override func logMessage(logMessage: DDLogMessage!) {
        var message = logMessage.message
        if let logFormatter = internalLogFormatter {
            message = logFormatter.formatLogMessage(logMessage)
        }
        
        storage.write(message)
    }
    
    func getLogs() -> String {
        return storage.read()
    }
}