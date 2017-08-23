#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MediaConstraintFlag) {
    
    // Audio
    MediaConstraintFlagAudio = (1 << 0),
    
    // Video
    MediaConstraintFlagVideo = (1 << 1),
    
    // Sharing
    MediaConstraintFlagScreenShare = (1 << 2)
};

#define DEFAULT_AUDIO_MAX_BANDWIDTH 64000
#define DEFAULT_VIDEO_MAX_BANDWIDTH 2000000

@interface MediaConstraint : NSObject

- (id)initWithConstraint:(NSUInteger)constraint;
- (id)initWithConstraint:(NSUInteger)constraint withAudioMaxBandWidth:(UInt32)audioMaxBandwidth withVideoMaxBandwidth:(UInt32)videomaxBandwidth;

@property (nonatomic, readonly) BOOL hasAudio;
@property (nonatomic, readonly) BOOL hasVideo;
@property (nonatomic, readonly) BOOL hasScreenShare;
@property (nonatomic, readonly) UInt32 audioMaxBandwidth;
@property (nonatomic, readonly) UInt32 videoMaxBandwidth;

@end
