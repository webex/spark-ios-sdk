typedef void(^ReachabilityCheckHandler)(NSString* result);

@interface MediaEngine : NSObject

@property (nonatomic, readonly) NSString *reachabilityResult;

+ (MediaEngine *)sharedInstance;
+ (NSString *)WMEVersion;

- (void)performStunReachabilityCheck:(NSDictionary*)clusterInfo completionHandler:(ReachabilityCheckHandler)handler;
- (void)clearReachabilityData;

@end
