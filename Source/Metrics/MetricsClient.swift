//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class MetricsClient {
    func post(metrics: HttpParameters, completionHandler: ServiceResponse<AnyObject> -> Void) {
        let request = ServiceRequest.Builder()
            .baseUrl(DeviceService.sharedInstance.getServiceUrl("metrics")!)
            .path("metrics")
            .method(.POST)
            .body(metrics)
            .build()
        
        request.responseJSON(completionHandler)
    }
}