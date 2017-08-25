//
//  MediaSessionBaseConfig.h
//  Wme
//
//  Created by panzh on 25/08/2017.
//  Copyright © 2017 cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_AUDIO_MAX_BANDWIDTH 64000
#define DEFAULT_VIDEO_MAX_BANDWIDTH 2000000

@interface MediaCapabilityConfig : NSObject

@property (nonatomic) UInt32 audioMaxBandwidth;
@property (nonatomic) UInt32 videoMaxBandwidth;

- (instancetype)initWithAudioMaxBandwidthOnly:(UInt32)audioBandwidth;
- (instancetype)initWithAudioMaxBandwidth:(UInt32)audioBandwidth withVideoMaxBandwidth:(UInt32)videoBandwidth;

@end
