// Copyright 2016-2017 Cisco Systems Inc
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

class MetricsEngine {

    private let metricsBufferLimit = 50
    private let metricsFlushIntervalSeconds: Double = 30
    private var metricsBuffer = MetricsBuffer()
    private lazy var periodicFlushTimer: Timer = Timer(timeInterval: self.metricsFlushIntervalSeconds,
                                                                target: self,
                                                                selector: #selector(flush),
                                                                userInfo: nil,
                                                                repeats: true)
    private let authenticator: Authenticator
    private let deviceService: DeviceService
    
    init(authenticator: Authenticator, deviceService: DeviceService) {
        self.authenticator = authenticator
        self.deviceService = deviceService
        
        RunLoop.current.add(periodicFlushTimer, forMode: RunLoopMode.commonModes)
    }
    
    func finishAllMetrics() {
        flush()
        periodicFlushTimer.invalidate()
    }
    
    //
    // Track a particular Metric. This will buffer the Metric and eventually send a batch of Metrics over the 
    // network to the Metrics Endpoint
    //
    func trackMetric(_ metric: Metric) {
        metricsBuffer.addMetric(metric)
        
        if metricsBuffer.count > metricsBufferLimit {
            flush()
        }
    }
    
    //
    // Track a set of Metrics. This will buffer the Metrics and eventually send a batch of Metrics over the 
    // network to the Metrics Endpoint
    //
    func trackMetrics(_ metrics: [Metric]) {
        metricsBuffer.addMetrics(metrics)
        
        if metricsBuffer.count > metricsBufferLimit {
            flush()
        }
    }
    
    //
    // Track a set of Metrics. This will send the Metrics over the network to the Metrics Endpoint immediately
    // without buffering metrics parameter is array of Metrics objects
    //
    func trackMetrics(_ metrics: [Metric], completionHandler: ((Bool) -> Void)? = nil) {
        if isDebuggerAttached() {
            SDKLogger.shared.warn("Skipping metric while debugging")
            return
        }
        
        var payloads: [Metric.DataType] = []
        for metric in metrics {
            if !metric.isValid {
                SDKLogger.shared.warn("Skipping invalid metric \(metric.name)")
                continue
            }
            
            let payload = constructPayloadFromMetric(metric)
            payloads.append(payload)
        }
        
        if payloads.count > 0 {
            postMetrics(RequestParameter(["metrics": payloads]), completionHandler: completionHandler)
        }
    }
    
    private func postMetrics(_ payload: RequestParameter, completionHandler: ((Bool) -> Void)?) {
        MetricsClient(authenticator: authenticator, deviceService: deviceService).post(payload) {
            (response: ServiceResponse<Any>) in
            switch response.result {
            case .success:
                SDKLogger.shared.info("Success: post metrics")
                completionHandler?(true)
                
            case .failure(let error):
                SDKLogger.shared.error("Failure", error: error)
                completionHandler?(false)
                break
            }
        }
    }
    
    private func constructPayloadFromMetric(_ metric: Metric) -> Metric.DataType {
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






