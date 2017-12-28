//
//  ActivityPostOperation.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/28.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit

class ActivityPostOperation: Operation {
    var postRequest : ServiceRequest
    var completionHandler :  (ServiceResponse<MessageActivity>) -> Void
    
    init(request: ServiceRequest, completionHandler: @escaping (ServiceResponse<MessageActivity>) -> Void) {
        self.postRequest = request
        self.completionHandler = completionHandler
    }
    
    override func main() {
        self.postRequest.responseObject(self.completionHandler)
    }
}
