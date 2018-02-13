
import UIKit
extension DateFormatter {
    
    private static func createIso8601WithMilliseconds() -> DateFormatter {
        let dateFormatter = DateFormatter()
        // Locale: See https://developer.apple.com/library/ios/qa/qa1480/_index.html
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }
    
    @objc public static let iso8601WithMilliseconds = DateFormatter.createIso8601WithMilliseconds()
    
    @objc public static func date(fromIso8601WithMillisecondsString dateString: String) -> Date? {
        return DateFormatter.iso8601WithMilliseconds.date(from: dateString)
    }
    
    @objc public static func string(fromIso8601WithMillisecondsDate date: Date) -> String {
        return DateFormatter.iso8601WithMilliseconds.string(from: date)
    }
    
    private static func createShortDateWithDash() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    public static let shortDateWithDash = DateFormatter.createShortDateWithDash()
    
    public static func date(fromShortDateWithDash dateString: String) -> Date? {
        return DateFormatter.shortDateWithDash.date(from: dateString)
    }
    
    public static func string(fromShortDateWithDash date: Date) -> String {
        return DateFormatter.shortDateWithDash.string(from: date)
    }
    
    private static func createLongFormatDate() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter
    }
    
    public static let longFormatDate = DateFormatter.createLongFormatDate()
    
    public static func date(fromLongFormatDate dateString: String) -> Date? {
        return DateFormatter.longFormatDate.date(from: dateString)
    }
    
    public static func string(fromLongFormatDate date: Date) -> String {
        return DateFormatter.longFormatDate.string(from: date)
    }
}
