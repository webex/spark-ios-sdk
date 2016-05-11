//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

class MetricsBuffer {
    private var metrics: [Metric] = []
    
    var count: Int {
        return metrics.count
    }
    
    func addMetric(metric: Metric) {
        metrics.append(metric)
    }
    
    func addMetrics(metrics: [Metric]) {
        self.metrics.appendContentsOf(metrics)
    }
    
    func popAll() -> [Metric] {
        let metricsCopy = metrics
        metrics.removeAll()
        
        return metricsCopy
    }
}
