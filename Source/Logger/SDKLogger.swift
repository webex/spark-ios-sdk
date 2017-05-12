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
    
    var console: LogLevel = LogLevel.debug
    
    var memory: Bool = true
    
    var logs: String? {
        return memory ? self.storage.read() : nil
    }
    
    private var storage = MemoryLoggerStorage()
    
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
        let timestamp = Date()
        let thread = Thread.current.name ?? ""
        let desc = format(logLevel: level, timestamp: timestamp, thread: thread, message: actualMessage, function: function)
        let log = LogMessage(message: actualMessage, level: level, file: file, function: function, line: line, description: desc, timestamp: timestamp, threadName: thread)
        
        func output() {
            if let logger = self.logger {
                logger.log(message: log)
            }
            if level.rawValue <= console.rawValue {
                print(desc)
                if memory {
                    self.storage.write(desc)
                }
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
        return self.format(logLevel: message.level, timestamp: message.timestamp, thread: message.threadName, message: message.message, function: message.function)
    }
    
    private func format(logLevel: LogLevel, timestamp: Date, thread: String, message: String, function: String) -> String {
        let timestamp: String = timestamp.longString
        var level: String
        switch (logLevel) {
        case .error:   level = "E"
        case .warning: level = "W"
        case .info:    level = "I"
        case .debug:   level = "D"
        case .verbose: level = "V"
        default:       level = "A"
        }
        return level + " " + timestamp + " " + "[" + thread + "]" + " | " + function + ": " + message
    }
}


class MemoryLoggerStorage {
    
    // configs
    private let BlockSize = 10*1024
    private let BlockCount = 1
    
    // storage
    private var blocks: [String]
    private var blockIndex = 0
    
    init() {
        blocks = [String](repeating: "", count: BlockCount)
    }
    
    func write(_ message: String) {
        synchronized(lock: self) {
            blocks[blockIndex] += message + "\n"
            if blocks[blockIndex].characters.count > BlockSize {
                blockIndex = (blockIndex + 1) % BlockCount
                blocks[blockIndex] = ""
            }
        }
    }
    
    func read() -> String {
        var output = ""
        synchronized(lock: self) {
            for offset in 1...BlockCount {
                output += blocks[(blockIndex + offset) % BlockCount]
            }
        }
        return output
    }
}
