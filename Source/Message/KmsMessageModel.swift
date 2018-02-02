//
//  KmsMessage.swift
//  SparkSDK
//
//  Created by qucui on 2017/12/26.
//  Copyright © 2017年 Cisco. All rights reserved.
//

import UIKit
import ObjectMapper

/// The struct of a KmsMessage on Cisco Spark.
///
/// - since: 1.4.0
public struct KmsMessageModel {
    /// The identifier of this message.
    public var destination: String?
    public var success : Bool?
    /// The Array of the messages
    public var kmsMessageStrs: [String]?
}

extension KmsMessageModel: Mappable {
    
    /// Message constructor.
    ///
    /// - note: for internal use only.
    public init?(map: Map){}
    
    /// Message mapping from JSON.
    ///
    /// - note: for internal use only.
    public mutating func mapping(map: Map) {
        destination <- map["destination"]
        success <- map["success"]
        kmsMessageStrs <- map["kmsMessages"]
    }
}
