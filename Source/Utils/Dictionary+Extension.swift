//
//  Dictionary+Extension.swift
//  Pods
//
//  Created by bxu3 on 4/29/16.
//
//

import Foundation
extension Dictionary {
    mutating func unionInPlace(dictionary: Dictionary) {
        dictionary.forEach { self.updateValue($1, forKey: $0) }
    }
    
    func union(dictionary: Dictionary) -> Dictionary {
        var newDictionary = dictionary
        newDictionary.unionInPlace(self)
        return newDictionary
    }
}