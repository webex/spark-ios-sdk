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

class MemoryLoggerStorage {

    // configs
    private let BlockSize = 10*1024
    private let BlockCount = 10

    // storage
    private var blocks: [String]
    private var blockIndex = 0
    
    init() {
        blocks = [String](repeating: "", count: BlockCount)
    }
    
    func write(_ message: String) {
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

    override func logMessage(_ logMessage: DDLogMessage!) {
        var message = logMessage.message
        if let logFormatter = internalLogFormatter {
            message = logFormatter.formatLogMessage(logMessage)
        }
        
        storage.write(message!)
    }
    
    func getLogs() -> String {
        return storage.read()
    }
}
