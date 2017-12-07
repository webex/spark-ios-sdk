#import "NSAttributedString+Extensions.h"

@implementation NSAttributedString (Extensions)

- (NSAttributedString *)attributedStringByTrimmingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange range = [self.string rangeOfCharacterFromSet:characterSet];
    NSMutableAttributedString *attributedString = [self mutableCopy];
    while (range.length != 0 && range.location == 0) {
        [attributedString replaceCharactersInRange:range withString:@""];
        range = [attributedString.string rangeOfCharacterFromSet:characterSet];
    }
    
    range = [attributedString.string rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch];
    while (range.length != 0 && NSMaxRange(range) == attributedString.length) {
        [attributedString replaceCharactersInRange:range withString:@""];
        range = [attributedString.string rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch];
    }
    
    return [attributedString copy];
}

- (NSRange)fullRange {
    return NSMakeRange(0, self.length);
}

@end
