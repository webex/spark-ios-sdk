#import "KmsRequest.h"

@interface KmsEphemeralKeyRequest : KmsRequest

@property (nonatomic, readonly) NSString *message;

/**
 Initialize a new KMS "create ephemeral key" request, intended for use by
 client code when initiating a secure channel with the KMS.
 */
- (instancetype)initWithRequestId:(NSString *)requestId
                         clientId:(NSString *)clientId
                           userId:(NSString *)userId
                           bearer:(NSString *)bearer
                           method:(NSString *)method
                              uri:(NSString *)uri
                     kmsStaticKey:(NSString *)kmsStaticKey
                            error:(NSError **)error;

/**
 Initialize a new KMS "create ephemeral key" request, using the specific 
 client EC key provided.  Clients SHOULD NOT use this init method for
 production, but rather use the similar init method above which will
 automatically generate a new random key for every call.  This method
 exists solely for the purpose of supporting unit test of interoperability
 with other KMS libraries.
 */
- (instancetype)initWithRequestId:(NSString *)requestId
                         clientId:(NSString *)clientId
                           userId:(NSString *)userId
                           bearer:(NSString *)bearer
                           method:(NSString *)method
                              uri:(NSString *)uri
                     kmsStaticKey:(NSString *)kmsStaticKey
                      clientEcKey:(NSString *)clientEcKey
                            error:(NSError **)error;

/**
 Read in an existing encrypted KMS "create ephemeral key" request, intended
 for use by unit test code, as this is behavior required only on the KMS server
 side.
 */
- (instancetype)initWithRequestMessage:(NSString *)message
                          kmsStaticKey:(NSString *)kmsStaticKey
                                 error:(NSError **)error;

@end
