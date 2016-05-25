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

/// Completion handler when getting service reponse for a request.
public class CompletionHandlerType<T> {
    
    /// Alias for closure to handle a service response along with an object.
    public typealias ObjectHandler = ServiceResponse<T> -> Void
    
    /// Alias for closure to handle a service response along with an object array.
    public typealias ArrayHandler = ServiceResponse<[T]> -> Void
    
    /// Alias for closure to handle a service response along with an object in type of AnyObject.
    public typealias AnyObjectHandler = ServiceResponse<AnyObject> -> Void
}