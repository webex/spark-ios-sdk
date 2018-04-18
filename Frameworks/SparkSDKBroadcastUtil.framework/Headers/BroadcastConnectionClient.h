//
//  SocketConnectionClient.h
//  iOSBroadcastExtension
//
//  Created by panzh on 09/03/2018.
//  Copyright © 2018 Cisco Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>
#import "SocketMessage.h"

@protocol BroadcastConnectionClientDelegate

@required
- (void)didReceivedError:(ScreenShareError)error;
- (void)didFailToSendFrame:(ScreenShareError)error;
@end

@interface BroadcastConnectionClient : NSObject 
- (instancetype)initWithApplicationGroupIdentifier:(NSString *)applicationGroupIdentifier delegate:(id <BroadcastConnectionClientDelegate>)delegate;
- (void)start:(void (^)(NSError *error))completion;
- (void)invalidate;
- (void)pushSampleBuffer:(CMSampleBufferRef)buffer;
- (void)sendMessage:(NSData *)message completion:(void (^)(NSError *error))completion;
@end
