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

class NotificationObserver: NSObject {
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var isObserving = false
    
    final func startObserving() {
        guard !isObserving else {
            return
        }
        
        addObserversFromMap(nil)
        isObserving = true
    }
    
    final func startObserving(sender: AnyObject?) {
        guard !isObserving else {
            return
        }
        
        addObserversFromMap(sender)
        isObserving = true
    }
    
    final func stopObserving() {
        guard isObserving else {
            return
        }
        
        notificationCenter.removeObserver(self)
        isObserving = false
    }
    
    func getNotificationHandlerMap() -> [String: String] {
        return [String: String]()
    }
    
    private func addObserver(selector: Selector, name: String, sender: AnyObject?) {
        notificationCenter.addObserver(self, selector: selector, name: name, object: sender)
    }
    
    private func addObserversFromMap(sender: AnyObject?) {
        let notificationhandlerMap = getNotificationHandlerMap()
        for (notification, selector) in notificationhandlerMap {
            addObserver(Selector(selector), name: notification, sender: sender)
        }
    }
}