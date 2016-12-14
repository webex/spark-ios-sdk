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


/// The data type include email validation and equatable implementation.
open class EmailAddress: Equatable {
    fileprivate var address: String
    
    private init(_ address: String) {
        self.address = address
    }
    
    /// Initialize EmailAddress from string
    ///
    /// - parameter address: The email address string.
    /// - returns: EmailAddress
    open static func fromString(_ address: String) -> EmailAddress? {
        guard isValid(address) else {
            return nil
        }
        
        return EmailAddress(address)
    }
    
    /// Get email address string from EmailAddress
    ///
    /// - returns: String
    open func toString() -> String {
        return address
    }
    
    private static func isValid(_ address: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: address)
    }
}

/// EmailAddress Equatable implementation. Check if two email addresses are equal.
///
/// - returns: Bool
public func ==(lhs: EmailAddress, rhs: EmailAddress) -> Bool {
    return lhs.address == rhs.address
}
