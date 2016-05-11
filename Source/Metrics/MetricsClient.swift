//
//  MetricsClient.swift
//  Pods
//
//  Created by bxu3 on 4/26/16.
//
//

import Alamofire

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