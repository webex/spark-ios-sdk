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

enum MetricsEnvironment: String {
    case Default = "DEFAULT"
    case Test = "TEST"
    case Production = "PRODUCTION"
}

enum MetricsCategory {
    // TODO: may need to update the category for SDK?
    case conversation
    case avatar
    case generic
}

enum MetricsType: String {
    case Increment = "INCREMENT"
    case Duration = "MSECS"
    case Gauge = "GAUGE"
    case Generic = "GENERIC"
}

struct Metric {
    typealias DataType = [String: Any]
    
    var name: String
    var data: DataType
    var type: MetricsType
    var environment: MetricsEnvironment
    var category: MetricsCategory
    var time: String
    var isBackground: Bool
    
    static let DataKey = "value"
    
    var isValid: Bool {
        return (name.characters.count > 0) && (data.count > 0)
    }
    
    init(name: String, data: DataType, type: MetricsType, environment: MetricsEnvironment, category: MetricsCategory) {
        self.name = name
        self.data = data
        self.type = type
        self.environment = environment
        self.category = category
        self.time = TimestampFormatter.nowInUTC()
        
        // TODO: need to check it when app supports background mode
        self.isBackground = false
    }
    
    static func incrementMetricWithName(_ name: String, category: MetricsCategory) -> Metric {
        return incrementMetricWithName(name, environment: MetricsEnvironment.Default, category: category)
    }
    
    static func incrementMetricWithName(_ name: String, environment: MetricsEnvironment, category: MetricsCategory) -> Metric {
        let data: DataType = [DataKey: ""]
        return Metric(name: name, data: data, type: MetricsType.Increment, environment: environment, category: category)
    }
    
    static func durationMetricWithName(_ name: String, milliseconds: Int, category: MetricsCategory) -> Metric {
        return durationMetricWithName(name, milliseconds: milliseconds, environment: MetricsEnvironment.Default, category: category)
    }
    
    static func durationMetricWithName(_ name: String, milliseconds: Int, environment: MetricsEnvironment, category: MetricsCategory) -> Metric {
        let data: DataType = [DataKey: String(milliseconds)]
        return Metric(name: name, data: data, type: MetricsType.Duration, environment: environment, category: category)
    }
    
    static func gaugeMetricWithName(_ name: String, value: Int, category: MetricsCategory) -> Metric {
        return gaugeMetricWithName(name, value: value, environment: MetricsEnvironment.Default, category: category)
    }
    
    static func gaugeMetricWithName(_ name: String, value: Int, environment: MetricsEnvironment, category: MetricsCategory) -> Metric {
        let data: DataType = [DataKey: String(value)]
        return Metric(name: name, data: data, type: MetricsType.Gauge, environment: environment, category: category)
    }
    
    static func genericMetricWithName(_ name: String, data: DataType) -> Metric {
        return genericMetricWithName(name, data: data, environment: MetricsEnvironment.Default)
    }
    
    static func genericMetricWithName(_ name: String, data: DataType, environment: MetricsEnvironment) -> Metric {
        return Metric(name: name, data: data, type: MetricsType.Generic, environment: environment, category: MetricsCategory.generic)
    }
}
