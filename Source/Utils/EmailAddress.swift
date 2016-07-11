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

public class EmailAddress: Equatable {
    private var address: String
    
    private init(_ address: String) {
        self.address = address
    }
    
    /// Initialize EmailAddress from string
    ///
    /// - parameter address: The email address string.
    /// - returns: EmailAddress
    public static func fromString(address: String) -> EmailAddress? {
        guard isValid(address) else {
            return nil
        }
        
        return EmailAddress(address)
    }
    
    /// Get email address string from EmailAddress
    ///
    /// - returns: String
    public func toString() -> String {
        return address
    }
    
    private static func isValid(address: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(address)
    }
}

/// EmailAddress Equatable implementation. Check if two email addresses are equal.
///
/// - returns: Bool
public func ==(lhs: EmailAddress, rhs: EmailAddress) -> Bool {
    return lhs.address == rhs.address
}