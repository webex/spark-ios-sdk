
#import <Foundation/Foundation.h>

@protocol CustomLogger

-(void)logVerbose:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logDebug:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logInfo:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logWarn:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logError:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;

@end





