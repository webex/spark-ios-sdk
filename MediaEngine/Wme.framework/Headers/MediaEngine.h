
typedef NS_ENUM(NSInteger, MediaEngineSdpDirection) {
    MediaEngineSdpDirectionUnknown = 0,
    MediaEngineSdpDirectionSendrecv, //media is processed by the device
    MediaEngineSdpDirectionRecvonly, 
    MediaEngineSdpDirectionInactive  //media is processed by paired room
};
typedef int AudioMuteState;


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
@property (nonatomic) BOOL crashWhenMediaEngineError;
@property (nonatomic, readonly, getter=isSimulcastEnabled) BOOL simulcastEnabled;

//
// Shared Instance class method. We should only have one instance of the Media Engine
// during execution. This is a good way to manage that. If the instance is not yet created,
// this will alloc, init, and configure a new instance.
//
+ (MediaEngine *)sharedInstance;

- (void)start;
- (void)stop;

- (void)createSdpOffer;
- (void)createSdpOfferForScreenRecvOnly;
- (void)setSdpDirection:(MediaEngineSdpDirection)newDirection;
- (void)receiveSdpAnswer:(MediaSession *)mediaSession sdp:(NSString *)sdp featureToggles:(NSDictionary *)featureToggles;
- (void)setSdpDirection:(MediaEngineSdpDirection)newDirection mediaType:(NSString *)mediaType;

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
// Start or stop the self-view. This can be done without being in a conversation
//
- (void)startSelfView:(MediaSession *)mediaSession;
- (void)stopSelfView;
//
// join or leave screen sharing. sharingId is unique id of sharing
//
- (void)joinSharing:(NSString *)sharingId;
- (void)leaveSharing:(NSString *)sharingId;

//
// Turn on or off the video stream
//
- (void)muteVideo;
- (void)unMuteVideo;

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

- (void)pushAudioMuteStateAndMuteAll;
- (void)popAudioMuteState;

//
// Switch Camera (front and back)
//
- (BOOL)isFrontCamera;
- (void)switchCameras;
- (void)setDefaultVideoCamera:(BOOL)isFront;

- (void)configureAudioSession;
- (void)switchSpeaker:(BOOL)isSpeaker;
- (BOOL)isSpeaker;

- (void)startSendingVideoFile:(NSString*)videoFilename isLoop:(BOOL)isLoop;
- (void)stopSendingVideoFile;

- (void)startSendingAudioFile:(NSString*)audioFilename isLoop:(BOOL)isLoop;
- (void)stopSendingAudioFile;

- (void)startRecordingVideoFile:(NSString*)videoFilename;
- (void)stopRecordingVideoFile;

- (void)startRecordingAudioFile:(NSString*)audioFilename;
- (void)stopRecordingAudioFile;

- (void)dumpAudioDebugFiles:(NSUInteger)duration;
- (NSMutableDictionary *)audioDumpFiles;
- (void)removeAudioDebugFiles;

- (NSDictionary *)mediaStatistics;
- (NSDictionary *)packetStatistics;

@end
