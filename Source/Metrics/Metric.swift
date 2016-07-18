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

enum MetricsEnvironment: String {
    case Default = "DEFAULT"
    case Test = "TEST"
    case Production = "PRODUCTION"
}

enum MetricsCategory {
    // TODO: may need to update the category for SDK?
    case Conversation
    case Avatar
    case Generic
}

enum MetricsType: String {
    case Increment = "INCREMENT"
    case Duration = "MSECS"
    case Gauge = "GAUGE"
    case Generic = "GENERIC"
}

struct Metric {
    typealias DataType = [String: AnyObject]
    
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
    
    static func incrementMetricWithName(name: String, category: MetricsCategory) -> Metric {
        return incrementMetricWithName(name, environment: MetricsEnvironment.Default, category: category)
    }
    
    static func incrementMetricWithName(name: String, environment: MetricsEnvironment, category: MetricsCategory) -> Metric {
        let data: DataType = [DataKey: ""]
        return Metric(name: name, data: data, type: MetricsType.Increment, environment: environment, category: category)
    }
    
    static func durationMetricWithName(name: String, milliseconds: Int, category: MetricsCategory) -> Metric {
        return durationMetricWithName(name, milliseconds: milliseconds, environment: MetricsEnvironment.Default, category: category)
    }
    
    static func durationMetricWithName(name: String, milliseconds: Int, environment: MetricsEnvironment, category: MetricsCategory) -> Metric {
        let data: DataType = [DataKey: String(milliseconds)]
        return Metric(name: name, data: data, type: MetricsType.Duration, environment: environment, category: category)
    }
    
    static func gaugeMetricWithName(name: String, value: Int, category: MetricsCategory) -> Metric {
        return gaugeMetricWithName(name, value: value, environment: MetricsEnvironment.Default, category: category)
    }
    
    static func gaugeMetricWithName(name: String, value: Int, environment: MetricsEnvironment, category: MetricsCategory) -> Metric {
        let data: DataType = [DataKey: String(value)]
        return Metric(name: name, data: data, type: MetricsType.Gauge, environment: environment, category: category)
    }
    
    static func genericMetricWithName(name: String, data: DataType) -> Metric {
        return genericMetricWithName(name, data: data, environment: MetricsEnvironment.Default)
    }
    
    static func genericMetricWithName(name: String, data: DataType, environment: MetricsEnvironment) -> Metric {
        return Metric(name: name, data: data, type: MetricsType.Generic, environment: environment, category: MetricsCategory.Generic)
    }
}
