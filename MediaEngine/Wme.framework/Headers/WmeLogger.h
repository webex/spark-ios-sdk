
#import <Foundation/Foundation.h>
#import "CustomLogger.h"
#import "WmeLogger.h"


@interface WmeLogger : NSObject

+(WmeLogger *)sharedInstance;

-(void)addLogger:(id<CustomLogger>)logger;

-(void)logVerbose:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logDebug:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logInfo:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logWarn:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logError:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;

@end





