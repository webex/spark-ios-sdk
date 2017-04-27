//
//  Participant.swift
//  SparkSDK
//
//  Created by zhiyuliu on 23/03/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

public struct CallMembership {

    public enum State : String {
        case unknown
        case idle
        case notified
        case joined
        case left
        case declined
    }
    
    public let id: String
    
    public let isInitiator: Bool
    
    public let presonId: String?

    public var state: State {
        return self.call.model[participant: self.id]?.state ?? .unknown
    }
    
    public var email: String? {
        return self.call.model[participant: self.id]?.person?.email
    }
    
    public var sipUrl: String? {
        return self.call.model[participant: self.id]?.person?.sipUrl
    }
    
    public var phoneNumber: String? {
        return self.call.model[participant: self.id]?.person?.phoneNumber
    }
        
    private let call: Call
    
    init(participant: ParticipantModel, call: Call) {
        self.id = participant.id ?? ""
        self.call = call
        self.isInitiator = participant.isCreator ?? false
        self.presonId = participant.person?.id
    }
}
