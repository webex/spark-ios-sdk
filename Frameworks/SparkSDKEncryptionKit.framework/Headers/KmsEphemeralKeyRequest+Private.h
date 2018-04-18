#import "KmsEphemeralKeyRequest.h"

#import "cjose/include/cjose/header.h"
#import "cjose/include/cjose/jws.h"
#import "cjose/include/cjose/version.h"
#import "cjose/include/cjose/jwk.h"
#import "cjose/include/cjose/base64.h"
#import "cjose/include/cjose/jwe.h"


@interface KmsEphemeralKeyRequest (Private)

@property (nonatomic, readonly) cjose_jwk_t *jwkKmsStaticKey;
@property (nonatomic, readonly) cjose_jwk_t *jwkEcKey;

@end
