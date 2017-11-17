//
//  FakeCallModelHelper.swift
//  SparkSDKTests
//
//  Created by panzh on 09/11/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
@testable import SparkSDK

class FakeCallModelHelper {
    enum CallIllegalStatusType  {
        case isRemoteLeft
        case missingCallUrl
    }
    
    static func dialCallModel(caller:TestUser,callee:TestUser) -> CallModel {
        let locusUrl = "locusUrl"
        let callerModel = PersonModel(JSON: ["name" : caller.name,
                                             "email" : caller.email,
                                             "id" : caller.personId,
                                             "orgId" : caller.orgId])
        
        let callerModelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "SENDRECV",
                                                                    "audioStatus" : "SENDRECV",
                                                                    "csis" : [
                                                                        955581697,
                                                                        4099885313,
                                                                        4099885312]])
        let alertHint = AlertHintModel(JSON: ["action" : "NONE"])
        let alertType = AlertTypeModel(JSON: ["action" : "NONE"])
        let callerDeviceModel = ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                    "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                    "mediaConnections" : [
                                                                        MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                                    "actionsUrl" : "actionsUrl",
                                                                                                    "remoteSdp" : "remoteSdp",
                                                                                                    "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                                    "localSdp" : "localSdp",
                                                                                                    "keepAliveSecs" : 20,
                                                                                                    "type" : "SDP"])],
                                                                    "deviceType" : "IPHONE",
                                                                    "url" : Config.FakeSelfDeviceUrl])
        
        let caller = ParticipantModel.init(isCreator: true,
                                           id: caller.personId ,
                                           url: "callerUrl",
                                           state: CallMembership.State.joined,
                                           type: "USER",
                                           person: callerModel,
                                           status:  callerModelStatus,
                                           deviceUrl: Config.FakeSelfDeviceUrl,
                                           mediaBaseUrl: "mediaBaseUrl",
                                           guest: false,
                                           alertHint: alertHint,
                                           alertType: alertType,
                                           enableDTMF: false,
                                           devices: [callerDeviceModel!])
        
        let host = callerModel
        
        let fullStateModel = FullStateModel(JSON: ["state" : "ACTIVE",
                                                   "locked" : false,
                                                   "active" : true,
                                                   "type" : "CALL",
                                                   "lastActive" : "2017-11-08T02:59:12.270Z",
                                                   "count" : 1])
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "0",
                                                 "entries" : [
                                                    "494027522700000",
                                                    "494027523130000",
                                                    "494027540210000"],
                                                 "rangeEnd" : "0"])
        
        let mediaShares1 = MediaShareModel(JSON: ["name" : "content",
                                                  "url" : "MediaShareModelUrl"])
        let mediaShares2 = MediaShareModel(JSON: ["name" : "whiteboard",
                                                  "url" : "MediaShareModelUrl"])
        
        
        
        let calleeModel = PersonModel(JSON: ["name" : callee.name,
                                             "email" : callee.email,
                                             "id" : callee.personId,
                                             "orgId" : callee.orgId])
        
        let calleeModelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "INACTIVE",
                                                                    "audioStatus" : "INACTIVE",
                                                                    "csis" : []])
        let callee = ParticipantModel.init(isCreator: true,
                                           id: callee.personId,
                                           url: "calleeUrl",
                                           state: CallMembership.State.idle,
                                           type: "USER",
                                           person: calleeModel,
                                           status:  calleeModelStatus,
                                           deviceUrl: Config.FakeOtherDeviceUrl,
                                           mediaBaseUrl: "mediaBaseUrl",
                                           guest: false,
                                           alertHint: nil,
                                           alertType: nil,
                                           enableDTMF: false,
                                           devices: [])
        
        return CallModel.init(locusUrl: locusUrl, participants: [caller,callee], myself: caller, host: host, fullState: fullStateModel, sequence: sequenceModel, replaces: nil, mediaShares: [mediaShares1!,mediaShares2!])
    }
    
    static func dialIllegalCallModel(caller:TestUser,callee:TestUser,type:CallIllegalStatusType) -> CallModel {
        var locusUrl:String? = "locusUrl"
        
        
        
        let callerModel = PersonModel(JSON: ["name" : caller.name,
                                             "email" : caller.email,
                                             "id" : caller.personId,
                                             "orgId" : caller.orgId])
        
        let callerModelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "SENDRECV",
                                                                    "audioStatus" : "SENDRECV",
                                                                    "csis" : [
                                                                        955581697,
                                                                        4099885313,
                                                                        4099885312]])
        let alertHint = AlertHintModel(JSON: ["action" : "NONE"])
        let alertType = AlertTypeModel(JSON: ["action" : "NONE"])
        let callerDeviceModel = ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                    "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                    "mediaConnections" : [
                                                                        MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                                    "actionsUrl" : "actionsUrl",
                                                                                                    "remoteSdp" : "remoteSdp",
                                                                                                    "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                                    "localSdp" : "localSdp",
                                                                                                    "keepAliveSecs" : 20,
                                                                                                    "type" : "SDP"])],
                                                                    "deviceType" : "IPHONE",
                                                                    "url" : Config.FakeSelfDeviceUrl])
        
        let caller = ParticipantModel.init(isCreator: true,
                                           id: caller.personId ,
                                           url: "callerUrl",
                                           state: CallMembership.State.joined,
                                           type: "USER",
                                           person: callerModel,
                                           status:  callerModelStatus,
                                           deviceUrl: Config.FakeSelfDeviceUrl,
                                           mediaBaseUrl: "mediaBaseUrl",
                                           guest: false,
                                           alertHint: alertHint,
                                           alertType: alertType,
                                           enableDTMF: false,
                                           devices: [callerDeviceModel!])
        
        let host = callerModel
        
        let fullStateModel = FullStateModel(JSON: ["state" : "ACTIVE",
                                                   "locked" : false,
                                                   "active" : true,
                                                   "type" : "CALL",
                                                   "lastActive" : "2017-11-08T02:59:12.270Z",
                                                   "count" : 1])
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "0",
                                                 "entries" : [
                                                    "494027522700000",
                                                    "494027523130000",
                                                    "494027540210000"],
                                                 "rangeEnd" : "0"])
        
        let mediaShares1 = MediaShareModel(JSON: ["name" : "content",
                                                  "url" : "MediaShareModelUrl"])
        let mediaShares2 = MediaShareModel(JSON: ["name" : "whiteboard",
                                                  "url" : "MediaShareModelUrl"])
        
        
        
        let calleeModel = PersonModel(JSON: ["name" : callee.name,
                                             "email" : callee.email,
                                             "id" : callee.personId,
                                             "orgId" : callee.orgId])
        
        let calleeModelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "INACTIVE",
                                                                    "audioStatus" : "INACTIVE",
                                                                    "csis" : []])
        
        var calleeState : CallMembership.State = .idle
        
        switch type {
        case .isRemoteLeft:
            calleeState = .left
        case .missingCallUrl:
            locusUrl = nil
        default:
            break
        }
        
        let callee = ParticipantModel.init(isCreator: true,
                                           id: callee.personId,
                                           url: "calleeUrl",
                                           state: calleeState,
                                           type: "USER",
                                           person: calleeModel,
                                           status:  calleeModelStatus,
                                           deviceUrl: Config.FakeOtherDeviceUrl,
                                           mediaBaseUrl: "mediaBaseUrl",
                                           guest: false,
                                           alertHint: nil,
                                           alertType: nil,
                                           enableDTMF: false,
                                           devices: [])
        
        return CallModel.init(locusUrl: locusUrl, participants: [caller,callee], myself: caller, host: host, fullState: fullStateModel, sequence: sequenceModel, replaces: nil, mediaShares: [mediaShares1!,mediaShares2!])
    }
    
    
    static func hangUpCallModel(callModel:CallModel,hanupUser:TestUser) -> CallModel {
        
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        
        if mySelf?.person?.id == hanupUser.personId {
            mySelf?.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "UNKNOWN",
                                                                 "audioStatus" : "UNKNOWN",
                                                                 "csis" : [1805773313,
                                                                           1805773312,
                                                                           242846209]])
            mySelf?.deviceUrl = Config.FakeSelfDeviceUrl
            mySelf?.state = CallMembership.State.left
            newModel.setMyself(newParticipant:mySelf)
            
            
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == hanupUser.personId {
                participant.state = CallMembership.State.left
                participant.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "INACTIVE",
                                                                         "audioStatus" : "INACTIVE",
                                                                         "csis" : []])
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        
        if newModel.participants?.filter({ $0.state == .joined }).count == 0 {
            var newFullState = newModel.fullState
            newFullState?.setState(newState: "INACTIVE")
            newFullState?.setCount(newCount: 0)
            newModel.setFullState(newFullState: newFullState)
            
        }
        
        
        
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "494076701580000",
                                                 "entries" : [
                                                    "494076856310000"],
                                                 "rangeEnd" : "494076709420000"])
        newModel.setSequence(newSequence: sequenceModel)
        
        return newModel
        
    }
    
    static func initCallModel(caller:TestUser,allParticipantUsers:[TestUser],selfUser:TestUser) -> CallModel {
        
        
        //self part
        let selfModel = PersonModel(JSON: ["name" : selfUser.name,
                                           "email" : selfUser.email,
                                           "id" : selfUser.personId,
                                           "orgId" : selfUser.orgId])
        var alertHint:AlertHintModel?
        var alertType:AlertTypeModel?
        
        var selfModelStatus:ParticipantModel.StatusModel?
        var selfDeviceModels:[ParticipantModel.DeviceModel] = []
        var selfState:CallMembership.State
        var isCreator: Bool?
        if caller.personId == selfUser.personId {
            selfModelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "SENDRECV",
                                                                  "audioStatus" : "SENDRECV",
                                                                  "csis" : [
                                                                    955581697,
                                                                    4099885313,
                                                                    4099885312]])
            if let device = ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                "mediaConnections" : [
                                                                    MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                                "actionsUrl" : "actionsUrl",
                                                                                                "remoteSdp" : "remoteSdp",
                                                                                                "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                                "localSdp" : "localSdp",
                                                                                                "keepAliveSecs" : 20,
                                                                                                "type" : "SDP"])],
                                                                "deviceType" : "IPHONE",
                                                                "url" : Config.FakeSelfDeviceUrl]) {
                selfDeviceModels.append(device)
            }
            
            selfState = CallMembership.State.joined
            isCreator = true
            alertHint = AlertHintModel(JSON: ["action" : "NONE"])
            alertType = AlertTypeModel(JSON: ["action" : "NONE"])
        }
        else {
            alertHint = AlertHintModel(JSON: ["expiration" : "2017-11-09T08:37:38.968Z",
            "action" : "RING"])
            alertType = AlertTypeModel(JSON: ["action" : "FULL"])
            
            selfModelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "INACTIVE",
                                                                  "audioStatus" : "INACTIVE",
                                                                  "csis" : []])
            selfState = .idle
            isCreator = false
        }
        
        
        let myself = ParticipantModel.init(isCreator: isCreator,
                                           id: selfUser.personId ,
                                           url: "callerUrl",
                                           state: selfState,
                                           type: "USER",
                                           person: selfModel,
                                           status:  selfModelStatus,
                                           deviceUrl: selfUser.personId == caller.personId ? Config.FakeSelfDeviceUrl:nil,
                                           mediaBaseUrl: "mediaBaseUrl",
                                           guest: false,
                                           alertHint: alertHint,
                                           alertType: alertType,
                                           enableDTMF: false,
                                           devices: selfDeviceModels)
        
        //caller part
        let callerModel = PersonModel(JSON: ["name" : caller.name,
                                             "email" : caller.email,
                                             "id" : caller.personId,
                                             "orgId" : caller.orgId])
        
        let host = callerModel
        
        //Participants part
        
        var participants:[ParticipantModel] = []
        
        for testUser in allParticipantUsers {
            
            let calleeModel = PersonModel(JSON: ["name" : testUser.name,
                                                 "email" : testUser.email,
                                                 "id" : testUser.personId,
                                                 "orgId" : testUser.orgId])
            var modelStatus:ParticipantModel.StatusModel?
            var deviceModels:[ParticipantModel.DeviceModel] = []
            var state:CallMembership.State
            var deviceUrl:String?
            var isCreator: Bool?
            if testUser.personId == caller.personId {
                modelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "SENDRECV",
                                                                  "audioStatus" : "SENDRECV",
                                                                  "csis" : [
                                                                    955581697,
                                                                    4099885313,
                                                                    4099885312]])
                deviceUrl = (testUser.personId == selfUser.personId ? Config.FakeSelfDeviceUrl : Config.FakeOtherDeviceUrl)
                
                if let device = ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                    "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                    "mediaConnections" : [
                                                                        MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                                    "actionsUrl" : "actionsUrl",
                                                                                                    "remoteSdp" : "remoteSdp",
                                                                                                    "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                                    "localSdp" : "localSdp",
                                                                                                    "keepAliveSecs" : 20,
                                                                                                    "type" : "SDP"])],
                                                                    "deviceType" : "IPHONE",
                                                                    "url" : deviceUrl!]) {
                                    deviceModels.append(device)
                }
                state = CallMembership.State.joined
                isCreator = true
            }
            else {
                modelStatus = ParticipantModel.StatusModel(JSON: ["videoStatus" : "INACTIVE",
                                                                  "audioStatus" : "INACTIVE",
                                                                  "csis" : []])
                state = CallMembership.State.idle
                deviceUrl = nil
                isCreator = false
            }
            
            let participant = ParticipantModel.init(isCreator: isCreator,
                                                    id: testUser.personId,
                                                    url: "calleeUrl",
                                                    state: state,
                                                    type: "USER",
                                                    person: calleeModel,
                                                    status:  modelStatus,
                                                    deviceUrl: deviceUrl,
                                                    mediaBaseUrl: "mediaBaseUrl",
                                                    guest: false,
                                                    alertHint: nil,
                                                    alertType: nil,
                                                    enableDTMF: false,
                                                    devices:deviceModels)
            participants.append(participant)
        }
        
        let locusUrl = "locusUrl+\(UUID.init())"
        
        let fullStateModel = FullStateModel(JSON: ["state" : "ACTIVE",
                                                   "locked" : false,
                                                   "active" : true,
                                                   "type" : "CALL",
                                                   "lastActive" : "2017-11-08T02:59:12.270Z",
                                                   "count" : 1])
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "0",
                                                 "entries" : [
                                                    "494027522700000",
                                                    "494027523130000",
                                                    "494027540210000"],
                                                 "rangeEnd" : "0"])
        
        let mediaShares1 = MediaShareModel(JSON: ["name" : "content",
                                                  "url" : "MediaShareModelUrl"])
        let mediaShares2 = MediaShareModel(JSON: ["name" : "whiteboard",
                                                  "url" : "MediaShareModelUrl"])
        
        
        
        
        
        return CallModel.init(locusUrl: locusUrl, participants: participants, myself: myself, host: host, fullState: fullStateModel, sequence: sequenceModel, replaces: nil, mediaShares: [mediaShares1!,mediaShares2!])
    }
    
    static func answerCallModel(callModel:CallModel,answerUser:TestUser) -> CallModel {
        
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        if mySelf?.person?.id == answerUser.personId {
            let csis:[UInt] = [1805773313,1805773312,242846209]
            mySelf?.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "SENDRECV",
                                                                 "audioStatus" : "SENDRECV",
                                                                 "csis" :csis])
            mySelf?.deviceUrl = Config.FakeSelfDeviceUrl

            let mediaConnection:MediaConnectionModel? = MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                              "actionsUrl" : "actionsUrl",
                                                              "remoteSdp" : "{\"audioMuted\":false,\"videoMuted\":false,\"type\":\"SDP\",\"csis\":[621971456,621971457,4244669953],\"sdp\":\"remoteSDP\"}",
                                                              "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                              "localSdp" : "{\"audioMuted\":false,\"videoMuted\":false,\"type\":\"SDP\",\"csis\":[621971456,621971457,4244669953],\"sdp\":\"localSDP\"}",
                                                              "keepAliveSecs" : 20,
                                                              "type" : "SDP"])!
            let mediaConnections:[MediaConnectionModel] = [mediaConnection!]
            
            var deviceModel = ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                  "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                  "mediaConnections" : mediaConnections,
                                                                  "deviceType" : "IPHONE",
                                                                  "url" : Config.FakeSelfDeviceUrl])
            deviceModel?.mediaConnections = mediaConnections
            mySelf?.devices = [deviceModel!]
            mySelf?.state = CallMembership.State.joined
            newModel.setMyself(newParticipant:mySelf)
            
            
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == answerUser.personId {
                participant.devices = [ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                           "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                           "mediaConnections" : [
                                                                            MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                                        "actionsUrl" : "actionsUrl",
                                                                                                        "remoteSdp" : "remoteSdp",
                                                                                                        "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                                        "localSdp" : "localSdp",
                                                                                                        "keepAliveSecs" : 20,
                                                                                                        "type" : "SDP"])],
                                                                           "deviceType" : "IPHONE",
                                                                           "url" : Config.FakeSelfDeviceUrl])!]
                participant.state = .joined
                participant.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "SENDRECV",
                                                                         "audioStatus" : "SENDRECV",
                                                                         "csis" : []])
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "494076701580000",
                                                 "entries" : [
                                                    "494076856310000"],
                                                 "rangeEnd" : "494076709420000"])
        newModel.setSequence(newSequence: sequenceModel)
        
        return newModel
        
    }
    
    static func declineCallModel(callModel:CallModel,declineUser:TestUser) -> CallModel {
        
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        
        if mySelf?.person?.id == declineUser.personId {
            mySelf?.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "UNKNOWN",
                                                                 "audioStatus" : "UNKNOWN",
                                                                 "csis" : [1805773313,
                                                                           1805773312,
                                                                           242846209]])
            mySelf?.deviceUrl = Config.FakeSelfDeviceUrl
            
            
            mySelf?.state = CallMembership.State.declined
            newModel.setMyself(newParticipant:mySelf)
            
            
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == declineUser.personId {
                
                participant.state = CallMembership.State.declined
                
                participant.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "INACTIVE",
                                                                         "audioStatus" : "INACTIVE",
                                                                         "csis" : []])
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        
        if newModel.participants?.filter({ $0.state == .joined }).count == 0 {
            var newFullState = newModel.fullState
            newFullState?.setState(newState: "INACTIVE")
            newFullState?.setCount(newCount: 0)
            newModel.setFullState(newFullState: newFullState)
            
        }
        
        
        
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "494076701580000",
                                                 "entries" : [
                                                    "494076856310000"],
                                                 "rangeEnd" : "494076709420000"])
        newModel.setSequence(newSequence: sequenceModel)
        
        return newModel
        
    }
    
    
    static func alertCallModel(callModel:CallModel,alertUser:TestUser) -> CallModel {
        
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        if mySelf?.person?.id == alertUser.personId {
            mySelf?.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "UNKNOWN",
                                                                 "audioStatus" : "UNKNOWN",
                                                                 "csis" : [1805773313,
                                                                           1805773312,
                                                                           242846209]])
            mySelf?.deviceUrl = Config.FakeSelfDeviceUrl
            mySelf?.devices = [ParticipantModel.DeviceModel(JSON: ["state" : "IDLE",
                                                                   "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                   "mediaConnections" : [
                                                                    MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                                "actionsUrl" : "actionsUrl",
                                                                                                "remoteSdp" : "remoteSdp",
                                                                                                "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                                "localSdp" : "localSdp",
                                                                                                "keepAliveSecs" : 20,
                                                                                                "type" : "SDP"])],
                                                                   "deviceType" : "IPHONE",
                                                                   "url" : Config.FakeSelfDeviceUrl])!]
            mySelf?.state = CallMembership.State.notified
            newModel.setMyself(newParticipant:mySelf)
            
            
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == alertUser.personId {
                participant.devices = [ParticipantModel.DeviceModel(JSON: ["state" : "IDLE",
                                                                           "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                           "mediaConnections" : [
                                                                            MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                                        "actionsUrl" : "actionsUrl",
                                                                                                        "remoteSdp" : "remoteSdp",
                                                                                                        "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                                        "localSdp" : "localSdp",
                                                                                                        "keepAliveSecs" : 20,
                                                                                                        "type" : "SDP"])],
                                                                           "deviceType" : "IPHONE",
                                                                           "url" : Config.FakeSelfDeviceUrl])!]
                participant.state = .notified
                participant.status = ParticipantModel.StatusModel(JSON: ["videoStatus" : "UNKNOWN",
                                                                         "audioStatus" : "UNKNOWN",
                                                                         "csis" : []])
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "494076701580000",
                                                 "entries" : [
                                                    "494076856310000"],
                                                 "rangeEnd" : "494076709420000"])
        newModel.setSequence(newSequence: sequenceModel)
        
        return newModel
        
    }
    
    static func updateMediaCallModel(callModel:CallModel,updateUser:TestUser,localMedia:MediaModel) -> CallModel {
        
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        if mySelf?.person?.id == updateUser.personId {
            
            if localMedia.audioMuted == true {
                mySelf?.status?.audioStatus = "RECVONLY"
            }
            else {
                mySelf?.status?.audioStatus = "SENDRECV"
            }
            if localMedia.videoMuted == true {
                mySelf?.status?.videoStatus = "RECVONLY"
            }
            else {
                mySelf?.status?.videoStatus = "SENDRECV"
            }
            let localSDP = "{\"audioMuted\":\(localMedia.audioMuted==true ? "true":"false"),\"videoMuted\":\(localMedia.videoMuted==true ? "true":"false"),\"type\":\"SDP\",\"csis\":[621971456,621971457,4244669953],\"sdp\":\"localSDP\"}"
            let mediaConnection:MediaConnectionModel? = MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                    "actionsUrl" : "actionsUrl",
                                                                                    "remoteSdp" : "{\"audioMuted\":false,\"videoMuted\":false,\"type\":\"SDP\",\"csis\":[621971456,621971457,4244669953],\"sdp\":\"remoteSDP\"}",
                                                                                    "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                    "localSdp" : localSDP,
                                                                                    "keepAliveSecs" : 20,
                                                                                    "type" : "SDP"])!
            let mediaConnections:[MediaConnectionModel] = [mediaConnection!]
            if let devices = mySelf?.devices {
            for var device in devices {
                device.mediaConnections = mediaConnections
            }
            }
            
            newModel.setMyself(newParticipant:mySelf)
            
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == updateUser.personId ,let devices = participant.devices {
                for var device in devices {
                    
                    let localSDP = "{\"audioMuted\":\(localMedia.audioMuted==true ? "true":"false"),\"videoMuted\":\(localMedia.videoMuted==true ? "true":"false"),\"type\":\"SDP\",\"csis\":[621971456,621971457,4244669953],\"sdp\":\"localSDP\"}"
                    let mediaConnection:MediaConnectionModel? = MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                                            "actionsUrl" : "actionsUrl",
                                                                                            "remoteSdp" : "{\"audioMuted\":false,\"videoMuted\":false,\"type\":\"SDP\",\"csis\":[621971456,621971457,4244669953],\"sdp\":\"remoteSDP\"}",
                                                                                            "mediaId" : "b3f69b17-0212-4c61-925e-497d2ad867d3",
                                                                                            "localSdp" : localSDP,
                                                                                            "keepAliveSecs" : 20,
                                                                                            "type" : "SDP"])!
                    device.mediaConnections = [mediaConnection!]
                }
               
                if localMedia.audioMuted == true {
                    participant.status?.audioStatus = "RECVONLY"
                }
                else {
                    participant.status?.audioStatus = "SENDRECV"
                }
                if localMedia.videoMuted == true {
                    participant.status?.videoStatus = "RECVONLY"
                }
                else {
                    participant.status?.videoStatus = "SENDRECV"
                }
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        
        let sequenceModel = SequenceModel(JSON: ["rangeStart" : "494076701580000",
                                                 "entries" : [
                                                    "494076856310000"],
                                                 "rangeEnd" : "494076709420000"])
        newModel.setSequence(newSequence: sequenceModel)
        
        return newModel
        
    }
    
    
}
