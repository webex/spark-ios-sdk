// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
            data["log"] = LoggerManager.sharedInstance.getMemoryLogs()
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
    
    func reportVideoLicenseActivation() {
        let metric = Metric.incrementMetricWithName(Metric.Call.ActivatingVideo, category: MetricsCategory.Generic)
        MetricsEngine.sharedInstance.trackMetric(metric)
    }
    
    private func createBasicCallData(callInfo: CallInfo) -> Metric.DataType {
        return ["locusId": callInfo.callUrl!,
                "locusTimestamp": callInfo.lastActive!,
                "deviceUrl": DeviceService.sharedInstance.deviceUrl!,
                "participantId": callInfo.selfId!,
                "isGroup": !callInfo.isOneOnOne,
                "wmeVersion": MediaEngineWrapper.sharedInstance.WMEVersion
        ]
    }
}