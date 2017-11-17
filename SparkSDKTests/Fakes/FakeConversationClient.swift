//
//  FakeConversationClient.swift
//  SparkSDKTests
//
//  Created by panzh on 08/11/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
@testable import SparkSDK
class FakeConversationClient : ConversationClient {
    var disableConversation: Bool = false
    override func getLocusUrl(conversation: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<ConversationLocusModel>) -> Void) {
        if disableConversation {
            completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.failure(SparkError.serviceFailed(code: -7000, reason: "getLocusUrl error"))))
        }
        else {
        completionHandler(ServiceResponse(HTTPURLResponse(url: URL(string: "www.aaa.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json;charset=UTF-8"]), Result.success(ConversationLocusModel.init(locusUrl: "locusUrl+\(UUID.init())"))))
        }
    }
}
