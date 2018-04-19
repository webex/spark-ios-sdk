#import "KmsResponse.h"

@class KmsEphemeralKeyRequest;

@interface KmsEphemeralKeyResponse : KmsResponse

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *jwkEphemeralKey;
@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSDate *expirationDate;

/**
 Initialize a new KMS "create ephemeral key" response, intended for use by
 client code upon receiving a response to a "create ephemeral key" request
 message.
 \param message The response message received from the KMS.
 \param request The request object used to generate the request message 
                previously sent to the KMS and to which this response message
                is responding.
 */
- (instancetype)initWithResponseMessage:(NSString *)message
                                request:(KmsEphemeralKeyRequest *)request
                                  error:(NSError **)error;

- (instancetype)initWithRequestMessage:(NSString *)message
                          kmsStaticKey:(NSString *)kmsStaticKey
                                 error:(NSError **)error;

/**
 intented for testing purposes.
 */
- (instancetype)initWithMessage:(NSString *)message jwkEphemeralKey:(NSString *)jwkEphemeralKey requestId:(NSString *)requestId expirationDate:(NSDate *)expirationDate;

@end
