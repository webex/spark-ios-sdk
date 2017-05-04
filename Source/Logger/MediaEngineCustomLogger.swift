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
import CocoaLumberjack
import Wme

class MediaEngineCustomLogger : CustomLogger {
    
    // May have some different log level setting on media engine
    let wmedefaultLevel = DDLogLevel.info
    
    @objc func logVerbose(_ message: String!, file: String!, function: String!, line: UInt) {
        SDKLogger.verbose(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logDebug(_ message: String!, file: String!, function: String!, line: UInt) {
        SDKLogger.debug(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logInfo(_ message: String!, file: String!, function: String!, line: UInt) {
        SDKLogger.info(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logWarn(_ message: String!, file: String!, function: String!, line: UInt) {
        SDKLogger.warn(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logError(_ message: String!, file: String!, function: String!, line: UInt) {
        SDKLogger.error(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
}
