#import <UIKit/UIKit.h>

@interface UIDevice (Extensions)

- (NSString *)platformCode;
- (NSString *)platformName;

- (BOOL)supportsMedia;
- (BOOL)supportsVideo;
- (BOOL)supportsHiResVideo;

- (BOOL)isiPhone;
- (BOOL)isiPad;

- (BOOL)isiOS8;

@end
