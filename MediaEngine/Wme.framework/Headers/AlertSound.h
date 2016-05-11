#import <Foundation/Foundation.h>

@class AudioSessionConfiguration;

typedef NS_ENUM(NSInteger, AlertSoundBehavior) {
    AlertSoundBehaviorDefault, // obey mute toggle, do not mix with others
    AlertSoundBehaviorMixWithOthers, // obey mute toggle, mix with others
    AlertSoundBehaviorNone // do not override audio configuration
};

@interface AlertSound : NSObject

+ (NSArray *)allSounds;

+ (instancetype)sharedIncomingCallAlertSound;
+ (instancetype)sharedIncomingGroupCallAlertSound;
+ (instancetype)sharedRingingCallAlertSound;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithContentsOfURL:(NSURL *)url behavior:(AlertSoundBehavior)behavior NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
- (void)play;
- (void)stop;

@end
