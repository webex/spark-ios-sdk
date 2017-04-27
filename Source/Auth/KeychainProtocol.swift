//
//  KeychainProtocol.swift
//  SparkSDK
//
//  Created by zhiyuliu on 23/04/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
import KeychainAccess

protocol KeychainProtocol {
    func get(_ key: String) throws -> String?
    func remove(_ key: String) throws
    func set(_ value: String, key: String) throws
}

extension Keychain: KeychainProtocol {}
