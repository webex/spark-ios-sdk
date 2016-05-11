//
//  MetricsBag.swift
//  Pods
//
//  Created by bxu3 on 4/27/16.
//
//

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
