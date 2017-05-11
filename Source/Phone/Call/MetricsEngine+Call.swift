//
//  MetricsEngine+Call.swift
//  SparkSDK
//
//  Created by zhiyuliu on 11/05/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

extension MetricsEngine {
    
    func trackCallReuqestMetric(call: Call) {
        guard var data = self.basicCallInfo(call: call) else { return }
        data["requestTimestamp"] = Timestamp.nowInUTC
        self.track(name: Metric.Call.Request, data)
    }
    
    func trackCallEndMetric(call: Call) {
        guard var data = self.basicCallInfo(call: call) else { return }
        data["clientCallDuration"] = String(self.milliseconds(from: call.metrics.callStartedTime, to: call.metrics.callEndedTime))
        if let reason = call.metrics.callEndedReason {
            data["endReason"] = String(describing: reason)
        }
        self.track(name: Metric.Call.End, data)
    }
    
    func trackFeedbackMetric(call: Call, rating: Int, comments: String?, includeLogs: Bool) {
        guard var data = self.basicCallInfo(call: call) else { return }
        data["user.rating"] = String(rating)
        data["user.comments"] = comments ?? ""
        if includeLogs {
            data["user.logs"] = SDKLogger.shared.logs
        }
        self.track(name: Metric.Call.Rating, data)
    }
    
    func trackVideoLicenseActivation() {
        self.track(name: Metric.Call.ActivatingVideo, type: MetricsType.Increment, ["value":""])
    }
    
    private func basicCallInfo(call: Call) -> [String: Any]? {
        guard let locus = call.model.locusUrl, let locusUrl = URL(string: locus) else {
            return nil
        }
        var data: [String: Any] = [
            "locusId": locusUrl.lastPathComponent,
            "locusTimestamp": call.model.fullState?.lastActive ?? "",
            "deviceUrl": call.device.deviceUrl,
            "participantId": call.model.myself?.id ?? "",
            "correlationId": call._uuid,
            "isGroup": !call.model.isOneOnOne,
            "initialMediaType": call.mediaSession.hasVideo ? "VIDEO" : "AUDIO",
            "wmeVersion": MediaEngineWrapper.sharedInstance.WMEVersion,
            "actor.id": call.model.host?.id ?? "",
            "actor.orgId": call.model.host?.orgId ?? "",
            "actor.personType": call.model.myself?.type ?? "",
            "actor.idType": self.authenticator is JWTAuthenticator ? "GuestID" : "SparkID"
        ]
        if let authenticator = self.authenticator as? OAuthAuthenticator {
            data["clientId"] = authenticator.clientId
        }
        return data
    }
    
    private func milliseconds(from: Date?, to: Date?) -> TimeInterval {
        guard let from = from, let to = to else { return -1 }
        return to.timeIntervalSince(from) * 1000
    }
    
}
