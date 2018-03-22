//
//  SparkConfig.swift
//  SparkSDK
//
//  Created by qucui on 2018/3/22.
//  Copyright © 2018年 Cisco. All rights reserved.
//

import UIKit
/// Spark Configuration
///
/// - since: 1.4.0
public class SparkConfig: NSObject {
    /// Auto retry mechanism switch.
    /// - since: 1.4.0
    public var RequestAutoRetryOn : Bool = true
    /// Request time out duration.
    /// - since: 1.4.0
    public var RequestTimeOut : Int = 180
}
