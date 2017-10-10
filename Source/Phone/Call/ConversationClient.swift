//
//  ConversationClient.swift
//  SparkSDK
//
//  Created by zhiyuliu on 20/08/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
import ObjectMapper

struct ConversationLocusModel {
    fileprivate(set) var locusUrl: String?
}

extension ConversationLocusModel: Mappable {
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        locusUrl <- map["url"]
    }
}

class ConversationClient {
    
    private let authenticator: Authenticator
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder(authenticator).keyPath("conversation")
    }
    
    func getLocusUrl(conversation: String, by device: Device, queue: DispatchQueue, completionHandler: @escaping (ServiceResponse<ConversationLocusModel>) -> Void) {
        let request = requestBuilder()
            .method(.get)
            .baseUrl(device.conversationServiceUrl)
            .path("conversations/\(conversation)/locus")
            .keyPath("")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
}
