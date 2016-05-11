//
//  String+Extension.swift
//  Pods
//
//  Created by bxu3 on 3/31/16.
//
//

import Foundation

extension String {
    var isEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluateWithObject(self)
    }
    
    var isUrl: Bool {
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluateWithObject(self)
    }
}