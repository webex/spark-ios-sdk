#import <Foundation/Foundation.h>

@class KmsEphemeralKeyRequest;
@class KmsEphemeralKeyResponse;
@class KmsRequest;

@protocol KmsMessageFactory
- (KmsRequest *)makeEphemeralKeyRequestWithDeviceUrl:(NSString *)deviceUrl userId:(NSString *)userId accessToken:(NSString *)accessToken kmsClusterUri:(NSString *)kmsClusterUri kmsStaticKey:(NSString *)kmsStaticKey;
- (KmsEphemeralKeyResponse *)makeEphemeralKeyResponse:(NSString *)message ephemeralKeyRequest:(KmsEphemeralKeyRequest *)ephemeralKeyRequest error:(NSError **)error;
@end
