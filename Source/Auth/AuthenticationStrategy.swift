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


/// A protocol for generic authentication strategies in Cisco Spark. Each authentication strategy
/// is responsible for providing an accessToken used throughout this SDK.
///
/// - since: 1.2.0
public protocol AuthenticationStrategy : class {
    
    /// True if the user is logically authorized. This may not mean the user has a valid
    /// access token yet, but the authentication strategy should be able to obtain one without
    /// further user interaction.
    var authorized: Bool { get }
    
    /// This function deauthorizes the current user and clears any persistent state with regards to the current user.
    /// If the *phone* is registered, it should be deregistered before calling this method.
    func deauthorize()
    
    /// This function returns an access token. This may involve long-running operations such as service calls,
    /// but may also return immediately. The application should not make assumptions about how quickly this
    /// completes.
    /// If the access token could not be retrieved then the completion handler will be called with nil.
    ///
    /// - parameter completionHandler: called when retrieval of the access token is complete
    func accessToken(completionHandler: @escaping (_ accessToken: String?) -> Void)
}
