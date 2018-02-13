#import "KmsEphemeralKeyRequest.h"

#import "cjose/header.h"
#import "cjose/jws.h"
#import "cjose/version.h"
#import "cjose/jwk.h"
#import "cjose/base64.h"
#import "cjose/jwe.h"

@interface KmsEphemeralKeyRequest (Private)

@property (nonatomic, readonly) cjose_jwk_t *jwkKmsStaticKey;
@property (nonatomic, readonly) cjose_jwk_t *jwkEcKey;

@end
