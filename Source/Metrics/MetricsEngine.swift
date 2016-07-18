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

class MetricsEngine {
    typealias CompletionHandlerType = Bool -> Void
    
    static let sharedInstance = MetricsEngine()
    
    private let MetricsBufferLimit = 50
    private let MetricsFlushIntervalSeconds: Double = 30
    private var metricsBuffer = MetricsBuffer()
    private var periodicFlushTimer: NSTimer!
    
    init() {
        periodicFlushTimer = NSTimer(timeInterval: MetricsFlushIntervalSeconds,
                                        target: self,
                                        selector: #selector(flush),
                                        userInfo: nil,
                                        repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(periodicFlushTimer, forMode: NSRunLoopCommonModes)
    }
    
    deinit {
        periodicFlushTimer.invalidate()
    }
    
    //
    // Track a particular Metric. This will buffer the Metric and eventually send a batch of Metrics over the 
    // network to the Metrics Endpoint
    //
    func trackMetric(metric: Metric) {
        metricsBuffer.addMetric(metric)
        
        if metricsBuffer.count > MetricsBufferLimit {
            flush()
        }
    }
    
    //
    // Track a set of Metrics. This will buffer the Metrics and eventually send a batch of Metrics over the 
    // network to the Metrics Endpoint
    //
    func trackMetrics(metrics: [Metric]) {
        metricsBuffer.addMetrics(metrics)
        
        if metricsBuffer.count > MetricsBufferLimit {
            flush()
        }
    }
    
    //
    // Track a set of Metrics. This will send the Metrics over the network to the Metrics Endpoint immediately
    // without buffering metrics parameter is array of Metrics objects
    //
    func trackMetrics(metrics: [Metric], completionHandler: CompletionHandlerType? = nil) {
        if isDebuggerAttached() {
            Logger.warn("Skipping metric while debugging")
            return
        }
        
        var payloads: [Metric.DataType] = []
        for metric in metrics {
            if !metric.isValid {
                Logger.warn("Skipping invalid metric \(metric.name)")
                continue
            }
            
            let payload = constructPayloadFromMetric(metric)
            payloads.append(payload)
        }
        
        if payloads.count > 0 {
            postMetrics(RequestParameter(["metrics": payloads]), completionHandler: completionHandler)
        }
    }
    
    private func postMetrics(payload: RequestParameter, completionHandler: CompletionHandlerType?) {
        MetricsClient().post(payload) {
            (response: ServiceResponse<AnyObject>) in
            switch response.result {
            case .Success:
                Logger.info("Success: post metrics")
                completionHandler?(true)
                
            case .Failure(let error):
                Logger.error("Failure: \(error.localizedFailureReason)")
                completionHandler?(false)
                break
            }
        }
    }
    
    private func constructPayloadFromMetric(metric: Metric) -> Metric.DataType {
        let postTime = TimestampFormatter.nowInUTC()
        var payload: Metric.DataType = ["key": metric.name,
                                        "postTime": postTime,
                                        "time": metric.time,
                                        "background": String(metric.isBackground)]
        payload.unionInPlace(metric.data)
        
        payload["evn"] = metric.environment.rawValue
        payload["type"] = metric.type.rawValue
        
        return payload
    }
    
    //
    // Manually flush any buffered metrics. Useful when we are going to background mode
    //
    @objc private func flush() {
        if metricsBuffer.count > 0 {
            trackMetrics(metricsBuffer.popAll(), completionHandler: nil)
        }
    }
}






