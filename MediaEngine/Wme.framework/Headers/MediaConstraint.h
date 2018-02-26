#import <Foundation/Foundation.h>
#import "MediaCapabilityConfig.h"
typedef NS_OPTIONS(NSUInteger, MediaConstraintFlag) {
    
    // Audio
    MediaConstraintFlagAudio = (1 << 0),
    
    // Video
    MediaConstraintFlagVideo = (1 << 1),
    
    // Sharing
    MediaConstraintFlagScreenShare = (1 << 2)
};

@interface MediaConstraint : NSObject

- (id)initWithConstraint:(NSUInteger)constraint;
- (id)initWithConstraint:(NSUInteger)constraint withCapability:(MediaCapabilityConfig *)capabilityConfig;

@property (nonatomic, readonly) BOOL hasAudio;
@property (nonatomic, readonly) BOOL hasVideo;
@property (nonatomic, readonly) BOOL hasScreenShare;
@property (nonatomic, readonly) MediaCapabilityConfig *capability;


@end
