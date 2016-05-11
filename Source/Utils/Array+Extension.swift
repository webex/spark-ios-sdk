//
//  Array+Extension.swift
//  SparkSDK
//
//  Created by xiuwenwu on 3/16/16.
//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
    
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}
