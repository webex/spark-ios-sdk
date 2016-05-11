//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

struct Feedback {
    var rating: Int
    var comments: String? = nil
    var includeLogs: Bool = false
    
    var metricData: Metric.DataType {
        var data: Metric.DataType = [:]
        
        data["rating"] = String(rating)
        
        if rating == 0 {
            data["declinedRating"] = String(true)
        }
        
        if includeLogs {
            // TODO: include log
            data["log"] = ""
        }
     
        return data
    }
}

class CallMetrics {
    static let sharedInstance = CallMetrics()
    
    private let TestUserEmailDomain = "example.com"
    
    func submitFeedback(feedback: Feedback, callInfo: CallInfo) {
        var data: Metric.DataType = createBasicCallData(callInfo)
        data.unionInPlace(feedback.metricData)
        
        var environment = MetricsEnvironment.Production
        if callInfo.participantsContiansEmailDomain(TestUserEmailDomain) {
            environment = MetricsEnvironment.Test
        }
        
        let metric = Metric.genericMetricWithName(Metric.Call.Rating, data: data, environment: environment)
        MetricsEngine.sharedInstance.trackMetric(metric)
    }
    
    private func createBasicCallData(callInfo: CallInfo) -> Metric.DataType {
        return ["locusId": callInfo.callUrl!,
                "locusTimestamp": callInfo.lastActive!,
                "deviceUrl": DeviceService.sharedInstance.deviceUrl!,
                "participantId": callInfo.selfId!,
                "isGroup": !callInfo.isOneOnOne,
                "wmeVersion": MediaEngine.sharedInstance.WMEVersion
        ]
    }
}