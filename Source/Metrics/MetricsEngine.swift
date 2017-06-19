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

    private let bufferLimit = 50
    private let client: MetricsClient
    private var buffer = MetricsBuffer()
    private lazy var timer: Timer = Timer(timeInterval: 30, target: self, selector: #selector(flush), userInfo: nil, repeats: true)
    let authenticator: Authenticator
    
    init(authenticator: Authenticator, service: DeviceService) {
        self.authenticator = authenticator
        self.client = MetricsClient(authenticator: authenticator, service: service)
        RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
    }

    func release() {
        flush()
        self.timer.invalidate()
    }

    func track(name: String, type: MetricsType = MetricsType.Generic, _ data: [String: String]) {
        self.track(metric: Metric(name: name, data: data))
    }
    
    private func track(metric: Metric) {
        self.buffer.add(metric: metric)
        if buffer.count > bufferLimit {
            flush()
        }
    }
    
    private func track(metrics: [Metric]) {
        self.buffer.add(metrics: metrics)
        if buffer.count > bufferLimit {
            flush()
        }
    }
    
    private func track(metrics: [Metric], completionHandler: ((Bool) -> Void)? = nil) {
        var payloads = [[String: Any]]()
        for metric in metrics {
            if metric.isValid {
                let payload = self.makePayloadWith(metric: metric)
                payloads.append(payload)
            }
            else {
                SDKLogger.shared.warn("Skipping invalid metric \(metric.name)")
            }
        }
        if payloads.count > 0 {
            self.client.post(RequestParameter(["metrics": payloads])) { response in
                SDKLogger.shared.debug("\(response)")
                switch response.result {
                case .success:
                    SDKLogger.shared.info("Success: post metrics")
                    completionHandler?(true)
                case .failure(let error):
                    SDKLogger.shared.error("Failure", error: error)
                    completionHandler?(false)
                }
            }
        }
    }
    
    private func makePayloadWith(metric: Metric) -> [String: String] {
        var payload: [String: String] = metric.data
        payload["key"] = metric.name
        payload["time"] = metric.time
        payload["postTime"] = Timestamp.nowInUTC
        payload["type"] = metric.type.rawValue
        if metric.background {
            payload["background"] = String(metric.background)
        }
        return payload
    }
    
    @objc func flush() {
        if buffer.count > 0 {
            if let metrics = buffer.popAll() {
                self.track(metrics: metrics, completionHandler: nil)
            }
        }
    }
    
}






