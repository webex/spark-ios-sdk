//
//  BroadcastExtensionLogger.h
//  iOSBroadcastExtension
//
//  Created by panzh on 13/03/2018.
//  Copyright © 2018 Cisco Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomLogger

-(void)logVerbose:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logDebug:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logInfo:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logWarn:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;
-(void)logError:(NSString *)message file:(NSString *)file function:(NSString *)function line:(NSUInteger)line;

@end

@interface BroadcastUtilLogger : NSObject

+(BroadcastUtilLogger *)sharedInstance;

-(void)addLogger:(id<CustomLogger>)logger;

-(void)logVerbose:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logDebug:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logInfo:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logWarn:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;
-(void)logError:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;


@end
