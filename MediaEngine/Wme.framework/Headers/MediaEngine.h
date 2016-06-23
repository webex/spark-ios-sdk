
typedef NS_ENUM(NSInteger, MediaEngineSdpDirection) {
    MediaEngineSdpDirectionUnknown = 0,
    MediaEngineSdpDirectionSendrecv, //media is processed by the device
    MediaEngineSdpDirectionRecvonly, 
    MediaEngineSdpDirectionInactive  //media is processed by paired room
};
typedef int AudioMuteState;

typedef void(^ReachabilityCheckHandler)(NSString* result);


@class MediaSession;
@class Sdp;

@interface MediaEngine : NSObject

/**
 Returns the version of WME in the format "major.minor.revision"
 */
+ (NSString *)WMEVersion;

@property (nonatomic, readonly) MediaSession *activeMediaSession;
@property (nonatomic) NSString *localWmeSdpOffer;
@property (nonatomic, readonly) BOOL audioOutputMuted;
@property (nonatomic, readonly) BOOL mediaAgentsCreated;
@property (nonatomic) BOOL lostNetworkConnection;
@property (nonatomic) BOOL alreadyWarnedNetworkCongestion;
@property (nonatomic) BOOL localVideoDisabled;
@property (nonatomic) BOOL callConnected;
@property (nonatomic, readonly, getter=isSimulcastEnabled) BOOL simulcastEnabled;
@property (nonatomic, readonly) NSString *reachabilityResult;
//
// Shared Instance class method. We should only have one instance of the Media Engine
// during execution. This is a good way to manage that. If the instance is not yet created,
// this will alloc, init, and configure a new instance.
//
+ (MediaEngine *)sharedInstance;

- (void)createSdpOffer:(MediaSession *)mediaSession;
- (void)receiveSdpAnswer:(MediaSession *)mediaSession sdp:(NSString *)sdp featureToggles:(NSDictionary *)featureToggles;

- (void)onMediaReady:(unsigned long)mid direction:(int)direction mediaType: (int)mediaType track: (void*)pTrack;
- (void)OnMediaBlocked:(unsigned long)mid vid:(unsigned long)vid blocked:(bool)blocked;
- (void)OnMediaStatus:(unsigned long)mid vid:(unsigned long)vid status:(int)status hasCSI:(bool)hasCSI csi:(unsigned int)csi;
- (void)onFirstPacketSent:(int)mediaType;
- (void)onFirstPacketReceived:(int)mediaType;
- (void)setMediaSessionIpAddressPortFromConnStats:(MediaSession *)mediaSession;
- (void)checkTcpFallback;

- (void)onMediaEngineError:(int)errorCode;
/**
 Adds a media session which may or may not become active.
 This will influence behaviors like proximity detection which are considered before there is an active session.
 */
- (void)addMediaSession:(MediaSession *)mediaSession;
- (void)removeMediaSession:(MediaSession *)mediaSession;

- (void)connectToCloudMediaEngineWithMediaSession:(MediaSession *)mediaSession;
//
// Close the connection. This is the same for both sides of the Media connection
// returns status to indicate if call that just ended actually went live and was successful.
//
- (BOOL)endMediaSession:(MediaSession *)mediaSession;

//
// Turn on or off the video stream
//
- (void)muteVideo;
- (void)unmuteVideo;

//
// Turn on or off the video output stream
//
- (void)muteVideoOutput;
- (void)unmuteVideoOutput;

//
// Turn on or off the audio stream
//
- (void)muteAudio;
- (void)unmuteAudio;

//
// Turn on or off the audio output stream
//
- (void)muteAudioOutput;
- (void)unmuteAudioOutput;

//
// Switch Camera (front and back)
//
- (BOOL)isFrontCamera;
- (void)switchCameras;
- (void)setDefaultVideoCamera:(BOOL)isFront;

- (void)configureAudioSession;
- (void)switchSpeaker:(BOOL)isSpeaker;
- (BOOL)isSpeaker;


//Reachability Check
- (void)performStunReachabilityCheck:(NSDictionary*)clusterInfo completionHandler:(ReachabilityCheckHandler)handler;
- (void)clearReachabilityData;

@end
