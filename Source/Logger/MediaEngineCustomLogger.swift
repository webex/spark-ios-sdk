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
import Wme

class MediaEngineCustomLogger : CustomLogger {
    
    // May have some different log level setting on media engine
    let wmedefaultLevel = DDLogLevel.Info
    
    @objc func logVerbose(message: String!, file: String!, function: String!, line: UInt) {
        Logger.verbose(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logDebug(message: String!, file: String!, function: String!, line: UInt) {
        Logger.debug(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logInfo(message: String!, file: String!, function: String!, line: UInt) {
        Logger.info(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logWarn(message: String!, file: String!, function: String!, line: UInt) {
        Logger.warn(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
    
    @objc func logError(message: String!, file: String!, function: String!, line: UInt) {
        Logger.error(message, level: wmedefaultLevel, file: file, function: function, line: line)
    }
}
