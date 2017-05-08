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

class SDKLogger {
    
    static let shared = SDKLogger()
    
    var logger: Logger?;
    
    var console: Bool = false
    
    var memory: Bool = true {
        didSet {
            self.storage = memory ? MemoryLoggerStorage() : nil
        }
    }
    
    var logs: String? {
        return memory ? self.storage?.read() : nil
    }
    
    private var storage: MemoryLoggerStorage?
    
    func verbose(_ message: @autoclosure () -> String, error: Error? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), error:error, level: LogLevel.verbose, file: file, function: function, line: line)
    }
    
    func debug(_ message: @autoclosure () -> String, error: Error? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), error:error, level: LogLevel.debug, file: file, function: function, line: line)
    }
    
    func info(_ message: @autoclosure () -> String, error: Error? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), error:error, level: LogLevel.info, file: file, function: function, line: line)
    }
    
    func warn(_ message: @autoclosure () -> String, error: Error? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), error:error, level: LogLevel.warning, file: file, function: function, line: line)
    }
    
	func error(_ message: @autoclosure () -> String, error: Error? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message(), error:error, level: LogLevel.error, file: file, function: function, line: line, asynchronous: false)
    }
    
    private func log(_ message: @autoclosure () -> String, error: Error?, level: LogLevel, file: String, function: String, line: UInt, asynchronous: Bool = true) {
        let actualMessage: String
        if let error = error {
            actualMessage = "\(message()): \(String(describing: error.localizedDescription))"
        } else {
            actualMessage = message()
        }
        let log = LogMessage(message: actualMessage, level: level, file: file, function: function, line: line, description: actualMessage, timestamp: Date(), threadName: Thread.current.name)
        
        func output() {
            if let logger = self.logger {
                logger.log(message: log)
            }
            if console {
                print(format(message: log))
            }
            if memory {
                self.storage?.write(format(message: log))
            }
        }
        
        if asynchronous {
            DispatchQueue.main.async {
                output()
            }
        }
        else {
            output()
        }
    }
    
    private func format(message: LogMessage) -> String {
        let timestamp: String = message.timestamp.longString
        let queueThread: String = message.threadName ?? ""
        
        var level: String
        switch (message.level) {
        case .error:   level = "E"
        case .warning: level = "W"
        case .info:    level = "I"
        case .debug:   level = "D"
        case .verbose: level = "V"
        }
        return level + " " + timestamp + " " + "[" + queueThread + "]" + " | " + message.function + ": " + message.message
    }
}


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
