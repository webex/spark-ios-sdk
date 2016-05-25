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

class MetricsClient {
    func post(metrics: RequestParameter, completionHandler: ServiceResponse<AnyObject> -> Void) {
        let request = ServiceRequest.Builder()
            .baseUrl(DeviceService.sharedInstance.getServiceUrl("metrics")!)
            .path("metrics")
            .method(.POST)
            .body(metrics)
            .build()
        
        request.responseJSON(completionHandler)
    }
}