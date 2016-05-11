#import <Foundation/Foundation.h>

@interface MicrophoneSelector : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;
- (void)start;
- (void)stop;

@end
