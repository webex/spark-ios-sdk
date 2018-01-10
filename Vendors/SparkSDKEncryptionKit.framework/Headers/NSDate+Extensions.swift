import Foundation

// These methods are added to NSDate to keep in sync with Swift Date
// Found in Date+Extensions.swift
extension NSDate {
    
    @objc public static func date(withHttpDateString httpDateString: String) -> Date? {
        return self.date(withHttpDateString:httpDateString)
//            Date.date(withHttpDateString: httpDateString)
    }
    
    @objc(dateBySubtractingTimeInterval:) public func subtractingTimeInterval(_ timeInterval: TimeInterval) -> Date {
        return self.subtractingTimeInterval(_:timeInterval)
//            (self as Date).subtractingTimeInterval(timeInterval)
    }
    
    @objc(isBeforeDate:) public func isBefore(_ date: Date) -> Bool {
        return self.isBefore(date)
    }
    
    @objc(isBeforeOrEqualToDate:) public func isBeforeOrEqual(to date: Date) -> Bool {
        return self.isBeforeOrEqual(to: date)
    }
    
    @objc(isAfterDate:) public func isAfter(_ date: Date) -> Bool {
        return self.isAfter(date)
    }
    
    @objc(isAfterOrEqualToDate:) public func isAfterOrEqual(to date: Date) -> Bool {
        return self.isAfterOrEqual(to: date)
    }
    
    @objc(isBetweenDate:andDate:) public func isBetween(_ earlyDate: Date, and lateDate: Date) -> Bool {
        return self.isBetween(earlyDate, and: lateDate)
    }
    
    @objc public func timeIntervalUntilNow() -> TimeInterval {
        return self.timeIntervalUntilNow()
    }
    
//    @objc public func timeIntervalUntilNow(with clock: Clock) -> TimeInterval {
//        return self.timeIntervalUntilNow(with: clock)
//    }
    
    @objc public func isDate(_ date: Date, withinInterval interval: TimeInterval) -> Bool {
        return self.isDate(date, withinInterval: interval)
    }
    
}
