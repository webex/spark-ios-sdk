#import <Foundation/Foundation.h>

@interface NSAttributedString (Extensions)

- (NSAttributedString *)attributedStringByTrimmingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSRange)fullRange;

@end
