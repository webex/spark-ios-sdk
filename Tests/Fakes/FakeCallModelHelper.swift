// Copyright 2016-2018 Cisco Systems Inc
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
@testable import SparkSDK

class FakeCallModelHelper {
    enum CallIllegalStatusType  {
        case isRemoteLeft
        case missingCallUrl
    }
    
    static func dialCallModel(caller:TestUser,callee:TestUser) -> CallModel {
        let locusUrl = FakeCallModelHelper.getLocusUrl()
        
        let myselfModel = getParticipant(userInfo: caller, userState: CallMembership.State.joined, isSelfModel: true, isCreater: true)
        
        let host = getPersonModel(testUser: caller)
        
        let callerParticipantModel = getParticipant(userInfo: caller, userState: CallMembership.State.joined, isCreater: true,deviceUrl: myselfModel.deviceUrl)
        let calleeParticipantModel = getParticipant(userInfo: callee, userState: CallMembership.State.idle, isCreater: false)
        
        
        let participants :[ParticipantModel] = [callerParticipantModel,calleeParticipantModel]
        
        let fullStateModel = getFullState(participants: participants)
        
        let sequenceModel = getSequenceModel()
        let mediaShares = getMediaShareModels()
        return CallModel.init(locusUrl: locusUrl, participants: participants, myself: myselfModel, host: host, fullState: fullStateModel, sequence: sequenceModel, replaces: nil, mediaShares: mediaShares)
    }
    
    static func dialIllegalCallModel(caller:TestUser,callee:TestUser,type:CallIllegalStatusType) -> CallModel {
        var callModel = dialCallModel(caller: caller, callee: callee)
        
        switch type {
        case .isRemoteLeft:
            var participants:[ParticipantModel] = []
            for var participant in callModel.participants! {
                if participant.person!.id == callee.personId {
                    participant.state = CallMembership.State.left
                }
                participants.append(participant)
            }
            callModel.setParticipants(newParticipants: participants)
        case .missingCallUrl:
            callModel.setLocusUrl(newLocusUrl: nil)
        }
        
        return callModel
    }
    
    
    static func hangUpCallModel(callModel:CallModel,hanupUser:TestUser) -> CallModel {
        
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        
        if mySelf?.person?.id == hanupUser.personId {
            mySelf?.status = getParticipantStatus(participantState: .left)
            mySelf?.state = CallMembership.State.left
            newModel.setMyself(newParticipant:mySelf)
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == hanupUser.personId {
                participant.state = CallMembership.State.left
                participant.status = getParticipantStatus(participantState: .left)
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        newModel.setFullState(newFullState: getFullState(participants: newModel.participants!))
        newModel.setSequence(newSequence: getSequenceModel())
        return newModel
        
    }
    
    static func initCallModel(caller:TestUser,allParticipantUsers:[TestUser],selfUser:TestUser) -> CallModel {
        //self part
        let isCreator = caller.personId == selfUser.personId ? true:false
        let selfState = caller.personId == selfUser.personId ? CallMembership.State.joined:CallMembership.State.idle
        let mySelf = getParticipant(userInfo: selfUser,userState: selfState,isSelfModel: true, isCreater: isCreator)
        
        //caller part
        let callerModel = getPersonModel(testUser: caller)
        
        let host = callerModel
        
        //Participants part
        
        var participants:[ParticipantModel] = []
        
        for testUser in allParticipantUsers {
            var state:CallMembership.State
            var isCreator: Bool = false
            if testUser.personId == caller.personId {
                isCreator = true
                state = CallMembership.State.joined
            }
            else {
                state = CallMembership.State.idle
                isCreator = false
            }
            let participant = getParticipant(userInfo: testUser, userState: state, isCreater: isCreator)
            participants.append(participant)
        }
        
        let locusUrl = getLocusUrl()
        
        let fullStateModel = getFullState(participants: participants)
        let sequenceModel = getSequenceModel()
        let mediaShareModels = getMediaShareModels()
        return CallModel.init(locusUrl: locusUrl, participants: participants, myself: mySelf, host: host, fullState: fullStateModel, sequence: sequenceModel, replaces: nil, mediaShares: mediaShareModels)
    }
    
    static func answerCallModel(callModel:CallModel,answerUser:TestUser) -> CallModel {
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        if mySelf?.person?.id == answerUser.personId {
            mySelf?.state = CallMembership.State.joined
            mySelf?.status = getParticipantStatus(participantState: CallMembership.State.joined)
            mySelf?.deviceUrl = Config.FakeSelfDeviceUrl
            mySelf?.devices = getParticipantDevice(participantState: CallMembership.State.joined, isSelfModel: true, deviceUrl: Config.FakeSelfDeviceUrl)
            newModel.setMyself(newParticipant:mySelf)
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == answerUser.personId {
                participant.state = .joined
                participant.deviceUrl = getDeviceUrl(isSelfModel: participant.person?.id == mySelf?.person?.id, userState: .joined,deviceUrl: participant.deviceUrl)
                participant.devices = getParticipantDevice(participantState: .joined, isSelfModel: false, deviceUrl: participant.deviceUrl)
                participant.status = getParticipantStatus(participantState: .joined)
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        newModel.setSequence(newSequence: getSequenceModel())
        
        return newModel
        
    }
    
    static func declineCallModel(callModel:CallModel,declineUser:TestUser) -> CallModel {
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        
        if mySelf?.person?.id == declineUser.personId {
            mySelf?.state = CallMembership.State.declined
            mySelf?.status = getParticipantStatus(participantState: CallMembership.State.declined)
            mySelf?.deviceUrl = Config.FakeSelfDeviceUrl
            newModel.setMyself(newParticipant:mySelf)
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == declineUser.personId {
                participant.state = CallMembership.State.declined
                participant.status = getParticipantStatus(participantState: CallMembership.State.declined)
            }
            participants.append(participant)
        }
        newModel.setParticipants(newParticipants: participants)
        
        newModel.setFullState(newFullState: getFullState(participants: newModel.participants!))
        newModel.setSequence(newSequence: getSequenceModel())
        return newModel
    }
    
    static func alertCallModel(callModel:CallModel,alertUser:TestUser) -> CallModel {
        var newModel = callModel
        var mySelf = newModel.myself
        var participants:[ParticipantModel] = []
        if mySelf?.person?.id == alertUser.personId {
            mySelf?.state = CallMembership.State.notified
            mySelf?.status = getParticipantStatus(participantState: .notified)
            mySelf?.deviceUrl = Config.FakeSelfDeviceUrl
            mySelf?.devices = getParticipantDevice(participantState: CallMembership.State.notified, isSelfModel: true, deviceUrl: Config.FakeSelfDeviceUrl)
            newModel.setMyself(newParticipant:mySelf)
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == alertUser.personId {
                participant.state = .notified
                participant.deviceUrl = getDeviceUrl(isSelfModel: participant.person?.id == mySelf?.person?.id, userState: .joined,deviceUrl: participant.deviceUrl)
                participant.devices = getParticipantDevice(participantState: CallMembership.State.notified, isSelfModel: false, deviceUrl: participant.deviceUrl)
                participant.status = getParticipantStatus(participantState: .notified)
            }
            participants.append(participant)
        }
        
        newModel.setParticipants(newParticipants: participants)
        newModel.setSequence(newSequence: getSequenceModel())
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
            
            let mediaConnection:MediaConnectionModel? = getMediaConectionModel(remoteAudioMuted: false, remoteVideoMuted: false, localAudioMuted: localMedia.audioMuted!, localVideoMuted: localMedia.videoMuted!)
            
            let mediaConnections:[MediaConnectionModel] = [mediaConnection!]
            if let devices = mySelf?.devices {
                var newDevices:[ParticipantModel.DeviceModel] = []
                for var device in devices {
                    device.mediaConnections = mediaConnections
                    newDevices.append(device)
                }
                mySelf?.devices = newDevices
            }
            newModel.setMyself(newParticipant:mySelf)
        }
        
        for var participant in newModel.participants! {
            if participant.person?.id == updateUser.personId {
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
        newModel.setSequence(newSequence: getSequenceModel())
        return newModel
    }
    
    static func getLocusUrl() -> String {
        return "locusUrl\(UUID.init())"
    }
    
    static func grantedScreenShareCallModel(callModel:CallModel,shareUser:TestUser) -> CallModel {
        return getGrantedScreenShareCallModel(callModel:callModel,shareUser:shareUser,isSelfDevice:false)
    }
    
    static func grantedLocalScreenShareCallModel(callModel:CallModel,shareUser:TestUser) -> CallModel {
        return getGrantedScreenShareCallModel(callModel:callModel,shareUser:shareUser,isSelfDevice:true)
    }
    
    static private func getGrantedScreenShareCallModel(callModel:CallModel,shareUser:TestUser,isSelfDevice:Bool) -> CallModel {
        var newModel = callModel
        var newMediaShares :[MediaShareModel] = []
        
        if let oldMediaShares = newModel.mediaShares {
            for var mediaShare in oldMediaShares {
                if mediaShare.shareType == MediaShareModel.MediaShareType.screen {
                    mediaShare = getGrantedScreenShareModel(shareUser: shareUser,isSelfDevice: isSelfDevice)
                }
                newMediaShares.append(mediaShare)
            }
        }
        else {
            newMediaShares.append(getGrantedScreenShareModel(shareUser: shareUser))
        }
        
        newModel.setMediaShares(newMediaShares: newMediaShares)
        return newModel
    }
    
    
    static func releaseScreenShareCallModel(callModel:CallModel,shareUser:TestUser) -> CallModel {
        return getReleaseScreenShareCallModel(callModel: callModel, shareUser: shareUser, isSelfDevice: false)
    }
    
    static func releaseLocalScreenShareCallModel(callModel:CallModel,shareUser:TestUser) -> CallModel {
        return getReleaseScreenShareCallModel(callModel: callModel, shareUser: shareUser, isSelfDevice: true)
    }
    
    static private func getReleaseScreenShareCallModel(callModel:CallModel,shareUser:TestUser,isSelfDevice:Bool) -> CallModel {
        var newModel = callModel
        var newMediaShares :[MediaShareModel] = []
        
        if let oldMediaShares = newModel.mediaShares {
            for var mediaShare in oldMediaShares {
                if mediaShare.shareType == MediaShareModel.MediaShareType.screen {
                    mediaShare = getReleaseScreenShareModel(shareUser: shareUser,isSelfDevice: isSelfDevice)
                }
                newMediaShares.append(mediaShare)
            }
        }
        else {
            newMediaShares.append(getReleaseScreenShareModel(shareUser: shareUser))
        }
        
        newModel.setMediaShares(newMediaShares: newMediaShares)
        return newModel
    }
    
    
    
    private static func getPersonModel(testUser:TestUser) -> PersonModel {
        return PersonModel(JSON: ["name" : testUser.name,
                                  "email" : testUser.email,
                                  "id" : testUser.personId,
                                  "orgId" : testUser.orgId])!
    }
    
    private static func getParticipantStatus(participantState:CallMembership.State) -> ParticipantModel.StatusModel {
        var statusModel :ParticipantModel.StatusModel?
        switch participantState {
        case .idle:
            statusModel = ParticipantModel.StatusModel(JSON: ["videoStatus" : "INACTIVE",
                                                              "audioStatus" : "INACTIVE",
                                                              "csis" : []])
        case .joined:
            statusModel = ParticipantModel.StatusModel(JSON: ["videoStatus" : "SENDRECV",
                                                              "audioStatus" : "SENDRECV",
                                                              "csis" : [111111,
                                                                        222222,
                                                                        333333]])
        case .declined,.left,.notified:
            statusModel = ParticipantModel.StatusModel(JSON: ["videoStatus" : "UNKNOWN",
                                                              "audioStatus" : "UNKNOWN",
                                                              "csis" : [111111,222222,333333]])
        }
        
        
        return statusModel!
    }
    
    private static func getParticipantDevice(participantState:CallMembership.State,isSelfModel:Bool = false,deviceUrl:String?) -> [ParticipantModel.DeviceModel] {
        
        var deviceModels:[ParticipantModel.DeviceModel] = []
        var deviceModel:ParticipantModel.DeviceModel? = nil
        
        switch participantState {
        case .idle,.declined,.left,.notified:
            break
        case .joined:
            if let url = deviceUrl {
                if isSelfModel == true {
                    let mediaConnections:[MediaConnectionModel] = [getMediaConectionModel()]
                    deviceModel = ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                      "callLegId" : "0908e0c4-1d37-4696-9e9c-1fb4f910eb13",
                                                                      "deviceType" : "IPHONE",
                                                                      "url" : url])
                    deviceModel?.mediaConnections = mediaConnections
                }
                else {
                    deviceModel = ParticipantModel.DeviceModel(JSON: ["state" : "JOINED",
                                                                      "deviceType" : "IPHONE",
                                                                      "url" : url])
                }
            }
        }
        
        if let device = deviceModel {
            deviceModels.append(device)
        }
        
        return deviceModels
    }
    
    private static func getMediaConectionModel(remoteAudioMuted:Bool = false,remoteVideoMuted:Bool = false,localAudioMuted: Bool = false,localVideoMuted: Bool = false) ->MediaConnectionModel {
        let remoteSDP = "{\"audioMuted\":\(remoteAudioMuted ? "false":"true"),\"videoMuted\":\(remoteVideoMuted ? "false":"true"),\"type\":\"SDP\",\"csis\":[6219714,6219714,42446699],\"sdp\":\"remoteSDP\"}"
        let localSDP = "{\"audioMuted\":\(localAudioMuted ? "false":"true"),\"videoMuted\":\(localVideoMuted ? "false":"true"),\"type\":\"SDP\",\"csis\":[6219714,6219714,42446699],\"sdp\":\"localSDP\"}"
        let mediaConnection:MediaConnectionModel = MediaConnectionModel(JSON: ["keepAliveUrl" : "keepAliveUrl",
                                                                               "actionsUrl" : "actionsUrl",
                                                                               "remoteSdp" : remoteSDP,
                                                                               "mediaId" : "\(UUID.init())",
                                                                               "localSdp" : localSDP,
                                                                               "keepAliveSecs" : 20,
                                                                               "type" : "SDP"])!
        return mediaConnection
    }
    
    private static func getFullState(participants:[ParticipantModel]) -> FullStateModel {
        var stateModel:FullStateModel = FullStateModel(JSON: ["state" : "ACTIVE",
                                                              "locked" : false,
                                                              "active" : true,
                                                              "type" : "CALL",
                                                              "lastActive" : "2017-11-08T02:59:12.270Z",
                                                              "count" : 1])!
        
        if participants.filter({ $0.state == .joined }).count == 0 {
            stateModel.setState(newState: "INACTIVE")
            stateModel.setCount(newCount: 0)
        }
        
        return stateModel
    }
    
    private static func getSequenceModel() -> SequenceModel {
        return SequenceModel(JSON: ["rangeStart" : "0",
                                    "entries" : [
                                        "4940275227",
                                        "4940275231",
                                        "4940275402"],
                                    "rangeEnd" : "0"])!
    }
    
    private static func getMediaShareModels() -> [MediaShareModel] {
        let whiteboard = MediaShareModel(JSON: ["name" : "whiteboard",
                                                "url" : "MediaShareModelUrl"])!
        let screenShare = MediaShareModel(JSON: ["name" : "content",
                                                 "url" : "MediaShareModelUrl"])!
        
        return [whiteboard,screenShare]
    }
    
    private static func getAlertHintModel(userState:CallMembership.State,isCreater:Bool,isSeflModel:Bool) ->AlertHintModel? {
        guard isSeflModel == true else {
            return nil
        }
        
        var alertHint:AlertHintModel? = nil
        switch userState {
        case .notified,.idle:
            if !isCreater {
                alertHint = AlertHintModel(JSON: ["expiration" : "2017-11-09T08:37:38.968Z",
                                                  "action" : "RING"])
                
            }
            break
        default:
            alertHint = AlertHintModel(JSON: ["action" : "NONE"])
            break
        }
        return alertHint
    }
    
    private static func getAlertTypeModel(userState:CallMembership.State,isCreater:Bool,isSeflModel:Bool) ->AlertTypeModel? {
        guard isSeflModel == true else {
            return nil
        }
        
        var alertType:AlertTypeModel? = nil
        switch userState {
        case .notified,.idle:
            if !isCreater {
                alertType = AlertTypeModel(JSON: ["action" : "FULL"])
            }
            break
        default:
            alertType = AlertTypeModel(JSON: ["action" : "NONE"])
            break
        }
        return alertType
    }
    
    private static func getDeviceUrl(isSelfModel:Bool,userState:CallMembership.State,deviceUrl:String? = nil) -> String? {
        var result: String? = nil
        switch userState {
        case .joined:
            if deviceUrl == nil {
                result = isSelfModel ? Config.FakeSelfDeviceUrl:Config.FakeOtherDeviceUrl
            }
            else {
                result = deviceUrl
            }
        default:
            break
        }
        return result
    }
    
    private static func getParticipant(userInfo:TestUser,userState:CallMembership.State,isSelfModel:Bool = false,isCreater:Bool,deviceUrl:String? = nil) -> ParticipantModel {
        let personModel = getPersonModel(testUser: userInfo)
        let userModelStatus = getParticipantStatus(participantState: userState)
        
        let alertHint = getAlertHintModel(userState: userState, isCreater: isCreater, isSeflModel: isSelfModel)
        let alertType = getAlertTypeModel(userState: userState, isCreater: isCreater, isSeflModel: isSelfModel)
        
        
        let selfDeviceUrl = getDeviceUrl(isSelfModel: isSelfModel, userState: userState,deviceUrl: deviceUrl)
        let callerDeviceModel = getParticipantDevice(participantState: userState,isSelfModel:isSelfModel,deviceUrl: selfDeviceUrl)
        let participantModel:ParticipantModel = ParticipantModel.init(isCreator: isCreater,
                                                                      id: userInfo.personId ,
                                                                      url: userInfo.personId,
                                                                      state: userState,
                                                                      type: "USER",
                                                                      person: personModel,
                                                                      status:  userModelStatus,
                                                                      deviceUrl: selfDeviceUrl,
                                                                      mediaBaseUrl: "mediaBaseUrl",
                                                                      guest: false,
                                                                      alertHint: alertHint,
                                                                      alertType: alertType,
                                                                      enableDTMF: false,
                                                                      devices: callerDeviceModel)
        
        return participantModel
    }
    
    private static func getGrantedScreenShareModel(shareUser:TestUser,isSelfDevice:Bool = false) -> MediaShareModel {
        let device:ParticipantModel.DeviceModel = ParticipantModel.DeviceModel.init(url: isSelfDevice ? Config.FakeSelfDeviceUrl:Config.FakeOtherDeviceUrl, deviceType: nil, featureToggles: nil, mediaConnections: nil, state: nil, callLegId: nil)
        let requestParticipant:ParticipantModel = ParticipantModel.init(isCreator: false, id: shareUser.personId, url: shareUser.personId, state: nil, type: "USER", person: nil, status: nil, deviceUrl: isSelfDevice ? Config.FakeSelfDeviceUrl:Config.FakeOtherDeviceUrl, mediaBaseUrl: nil, guest: false, alertHint: nil, alertType: nil, enableDTMF: nil, devices: [device])
        
        let dateString = String(describing: Date())
        let mediaShareFloor : MediaShareModel.MediaShareFloor = MediaShareModel.MediaShareFloor.init(beneficiary: requestParticipant, disposition: MediaShareModel.ShareFloorDisposition.granted, granted: dateString, released: nil, requested: dateString, requester: requestParticipant)
        
        return MediaShareModel.init(shareType: MediaShareModel.MediaShareType.screen, url: "MediaShareModelUrl", shareFloor: mediaShareFloor)
    }
    
    private static func getReleaseScreenShareModel(shareUser:TestUser,isSelfDevice:Bool = false) -> MediaShareModel {
        let device:ParticipantModel.DeviceModel = ParticipantModel.DeviceModel.init(url: isSelfDevice ? Config.FakeSelfDeviceUrl:Config.FakeOtherDeviceUrl, deviceType: nil, featureToggles: nil, mediaConnections: nil, state: nil, callLegId: nil)
        let requestParticipant:ParticipantModel = ParticipantModel.init(isCreator: false, id: shareUser.personId, url: shareUser.personId, state: nil, type: "USER", person: nil, status: nil, deviceUrl: isSelfDevice ? Config.FakeSelfDeviceUrl:Config.FakeOtherDeviceUrl, mediaBaseUrl: nil, guest: false, alertHint: nil, alertType: nil, enableDTMF: nil, devices: [device])
        
        let dateString = String(describing: Date())
        let mediaShareFloor : MediaShareModel.MediaShareFloor = MediaShareModel.MediaShareFloor.init(beneficiary: requestParticipant, disposition: MediaShareModel.ShareFloorDisposition.released, granted: dateString, released: dateString, requested: dateString, requester: requestParticipant)
        
        return MediaShareModel.init(shareType: MediaShareModel.MediaShareType.screen, url: "MediaShareModelUrl", shareFloor: mediaShareFloor)
    }
    
}
