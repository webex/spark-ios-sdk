@interface TimestampFormatter : NSObject

+ (NSString *)formattedTimestampFromDate:(NSDate *)date detailed:(BOOL)detailed;
+ (NSString *)utcFormattedTimestampFromDate:(NSDate *)date;
+ (NSString *)currentUtcFormattedTimestamp;
+ (NSString *)formattedTimestampFromStartTime:(NSDate *)startDate toEndTime:(NSDate *)endDate;
+ (NSString *)formattedDayFromDate:(NSDate *)date;
+ (NSString *)formattedYearFromDate:(NSDate *)date;
+ (NSString *)formattedMonthAbbreviationFromDate:(NSDate *)date;
+ (NSString *)formattedDurationFromTimeInterval:(NSTimeInterval)timeInterval;
+ (NSString *)formattedElapsedTimeFromTimeInterval:(NSTimeInterval)timeInterval;

@end
