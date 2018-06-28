//
//  BroadcastConnectionServer.h
//  iOSBroadcastExtension
//
//  Created by panzh on 13/03/2018.
//  Copyright © 2018 Cisco Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketMessage.h"
@protocol BroadcastConnectionServerDelegate

@required
- (Boolean)shouldAcceptNewConnection;
- (void)didReceivedFrame:(FrameInfo)frame frameData:(NSData *)frameData;
- (void)didReceivedError:(ScreenShareError)error;
@end


@interface BroadcastConnectionServer : NSObject
- (instancetype)initWithApplicationGroupIdentifier:(NSString *)applicationGroupIdentifier delegate:(id <BroadcastConnectionServerDelegate>)delegate;
- (void)start:(void (^)(NSError *error))completion;
- (void)invalidate;
- (void)broadcastMessage:(NSData *)message completion:(void (^)(NSError *error))completion;
@end
