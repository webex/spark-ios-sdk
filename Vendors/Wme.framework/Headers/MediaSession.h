#import <Foundation/Foundation.h>
#import "MediaConstraint.h"
#import "FrameInfo.h"
@class MediaRenderView;

@interface MediaSession : NSObject

// SDP & constraint
@property (nonatomic) NSString *localSdpOffer;
@property (nonatomic) MediaConstraint *mediaConstraint;

// audio & video
@property (nonatomic) BOOL audioMuted;
@property (nonatomic) BOOL videoMuted;
@property (nonatomic) BOOL screenShareMuted;
@property (nonatomic) BOOL audioOutputMuted;
@property (nonatomic) BOOL videoOutputMuted;
@property (nonatomic) BOOL screenShareOutputMuted;

@property (nonatomic) BOOL sendAudio;
@property (nonatomic) BOOL sendVideo;
@property (nonatomic) BOOL sendScreenShare;
@property (nonatomic) BOOL receiveAudio;
@property (nonatomic) BOOL receiveVideo;
@property (nonatomic) BOOL receiveScreenShare;

// render view
@property (nonatomic) MediaRenderView *localVideoView;
@property (nonatomic) MediaRenderView *remoteVideoView;
@property (nonatomic) MediaRenderView *screenShareView;
@property (nonatomic) unsigned int localVideoViewHeight;
@property (nonatomic) unsigned int localVideoViewWidth;
@property (nonatomic) unsigned int remoteVideoViewHeight;
@property (nonatomic) unsigned int remoteVideoViewWidth;
@property (nonatomic) unsigned int localScreenShareViewHeight;
@property (nonatomic) unsigned int localScreenShareViewWidth;
@property (nonatomic) unsigned int remoteScreenShareViewHeight;
@property (nonatomic) unsigned int remoteScreenShareViewWidth;

// proximity
@property (nonatomic) BOOL proximityPreferred;

- (void)createMediaConnection;

- (void)setDefaultCamera:(BOOL)useFront;
- (void)toggleCamera;
- (BOOL)isFrontCameraSelected;
- (void)setCamrea:(BOOL)frontCamera;

- (void)setDefaultAudioOutput:(BOOL)useSpeaker;
- (void)toggleSpeaker;
- (BOOL)isSpeakerSelected;
- (void)setSpeaker:(BOOL)useSpeaker;

- (void)muteAudio;
- (void)muteVideo;
- (void)muteScreenShare;
- (void)muteAudioOutput;
- (void)muteVideoOutput;
- (void)muteScreenShareOutput;
- (void)unmuteAudio;
- (void)unmuteVideo;
- (void)unmuteScreenShare;
- (void)unmuteAudioOutput;
- (void)unmuteVideoOutput;
- (void)unmuteScreenShareOutput;

- (void)stopAudio;
- (void)startAudio;

- (NSString*)createLocalSdpOffer;
- (void)receiveRemoteSdpAnswer:(NSString*)sdp;

- (void)connectToCloud;
- (void)disconnectFromCloud;

- (void)startLocalVideoRenderView;
- (void)stopLocalVideoRenderView:(BOOL)removeRender;
- (void)startRemoteVideoRenderView;
- (void)stopRemoteVideoRenderView:(BOOL)removeRender;
- (void)startScreenShareRenderView;
- (void)stopScreenShareRenderView:(BOOL)removeRender;

- (void)joinScreenShare:(NSString *)shareId isSending:(BOOL)isSending;
- (void)leaveScreenShare:(NSString *)shareId isSending:(BOOL)isSending;
- (void)startLocalScreenShare;
- (void)stopLocalScreenShare;
- (void)onReceiveScreenBroadcastData:(FrameInfo)frameInfo frameData:(NSData *)frameData;

- (void)updateSdpDirectionWithLocalView:(MediaRenderView *)localView remoteView:(MediaRenderView *)remoteView;
- (void)updateSdpDirectionWithScreenShare:(MediaRenderView *)screenShareView;
@end
