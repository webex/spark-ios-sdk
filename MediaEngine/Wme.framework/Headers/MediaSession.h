#import <Foundation/Foundation.h>
#import "MediaConstraint.h"

@class MediaRenderView;

typedef enum  {
    mediaSessionIdle = 0,
    mediaSessionConnecting,
    mediaSessionConnected,
    mediasessionDisconnecting,
    mediaSessionDisconnected
} mediaSessionConnectionState ;

// The MediaSession encapsulates the information needed to start, manage, and end a MediaSession
@interface MediaSession : NSObject

@property (nonatomic) MediaConstraint *mediaConstraint;

@property (nonatomic) mediaSessionConnectionState audioConnectionState;
@property (nonatomic) mediaSessionConnectionState videoConnectionState;

// local
@property (nonatomic, copy) NSString *localIPAddress;
@property (nonatomic) int audioReceiveOnPort;
@property (nonatomic) int videoReceiveOnPort;

// remote
@property (nonatomic, copy) NSString *remoteAudioIPAddress;
@property (nonatomic, copy) NSString *remoteVideoIPAddress;
@property (nonatomic) NSInteger remoteAudioPort;
@property (nonatomic) NSInteger remoteVideoPort;

// These views are to Render the incoming video stream and to show to LocalPreview
@property (nonatomic) MediaRenderView *renderView;
@property (nonatomic) MediaRenderView *localPreviewView;

@property (nonatomic) BOOL receiveVideo;
@property (nonatomic) BOOL receiveScreen;
@property (nonatomic) BOOL receiveAudio;
@property (nonatomic) BOOL sendVideo;
@property (nonatomic) BOOL previewVideo;
@property (nonatomic) BOOL sendAudio;
@property (nonatomic) BOOL audioMuted;
@property (nonatomic) BOOL audioOutputMuted;
@property (nonatomic, getter=isAudioMutedByInterruption) BOOL audioMutedByInterruption;
@property (nonatomic) BOOL videoMuted;
@property (nonatomic) BOOL videoOutputMuted;
@property (nonatomic, readonly, getter=isMediaActive) BOOL mediaActive;
@property (nonatomic, readonly, getter=isReceivingMedia) BOOL receivingMedia;
@property (nonatomic) BOOL receivedAtLeastOneVideoPacket;
@property (nonatomic) BOOL receivedAtLeastOneAudioPacket;
@property (nonatomic) BOOL sentAtLeastOneVideoPacket;
@property (nonatomic) BOOL sentAtLeastOneAudioPacket;
@property (nonatomic) float outputVolumeAtEndOfCall;

// Height and Width are reported by the WME
@property (nonatomic) uint32_t videoDecoderHeight;
@property (nonatomic) uint32_t videoDecoderWidth;
@property (nonatomic) uint32_t selfViewRenderHeight;
@property (nonatomic) uint32_t selfViewRenderWidth;

@property (nonatomic, copy) NSString *trackingId;

@property (nonatomic) BOOL prefersProximityMonitoringEnabled;

- (NSString *)description;
- (NSString *)mediaSessionConnectionStateDescription:(mediaSessionConnectionState)state;

@end
