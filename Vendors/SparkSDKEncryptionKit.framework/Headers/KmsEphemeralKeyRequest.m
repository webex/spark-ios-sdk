#import "KmsEphemeralKeyRequest+Private.h"

#import "CjoseWrapper+Private.h"
#import "NSDictionary+Extensions.h"

@interface KmsEphemeralKeyRequest ()

@property (nonatomic, readwrite) NSUInteger sequence;
@property (nonatomic, readwrite) NSString *clientId;
@property (nonatomic, readwrite) NSString *userId;
@property (nonatomic, readwrite) NSString *bearer;
@property (nonatomic, readwrite) NSString *method;
@property (nonatomic, readwrite) NSString *uri;
@property (nonatomic, readwrite) NSString *message;
@property (nonatomic, readwrite) cjose_jwk_t *jwkKmsStaticKey;
@property (nonatomic, readwrite) cjose_jwk_t *jwkEcKey;

@end

@implementation KmsEphemeralKeyRequest

@synthesize sequence = _sequence;
@synthesize clientId = _clientId;
@synthesize userId = _userId;
@synthesize bearer = _bearer;
@synthesize method = _method;
@synthesize uri = _uri;
@synthesize message = _message;
@synthesize jwkKmsStaticKey = _jwkKmsStaticKey;
@synthesize jwkEcKey = _jwkEcKey;

- (instancetype)initWithRequestId:(NSString *)requestId
                         clientId:(NSString *)clientId
                           userId:(NSString *)userId
                           bearer:(NSString *)bearer
                           method:(NSString *)method
                              uri:(NSString *)uri
                     kmsStaticKey:(NSString *)kmsStaticKey
                            error:(NSError **)error {
    
    cjose_err err;
    err.code = CJOSE_ERR_NONE;
    NSError *nserr;
    cjose_jwk_t *jwkEcKey = NULL;
    char *cstrEcKey = NULL;
    
    // create a client-side ephemeral EC key pair as a jwk
    if (nil == nserr) {
        jwkEcKey = cjose_jwk_create_EC_random(CJOSE_JWK_EC_P_256, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // serialize the full EC key pair
    if (nil == nserr) {
        cstrEcKey = cjose_jwk_to_json(jwkEcKey, true, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }

    // initialize self using generated EC key pair
    if (nil == nserr) {
        NSString *clientEcKey = [NSString alloc];
        clientEcKey = [clientEcKey initWithBytesNoCopy:cstrEcKey
                                                length:strlen(cstrEcKey)
                                              encoding:NSUTF8StringEncoding
                                          freeWhenDone:NO];

        self = [self initWithRequestId:requestId
                              clientId:clientId
                                userId:userId
                                bearer:bearer
                                method:method
                                   uri:uri
                          kmsStaticKey:kmsStaticKey
                           clientEcKey:clientEcKey
                                 error:error];
    }
    
    // cleanup
    cjose_jwk_release(jwkEcKey);
    free(cstrEcKey);
    
    // error handling
    if (nil != nserr) {
        self = nil;
        if (error) {
            *error = nserr;
        }
    }
    
    return self;
}

- (instancetype)initWithRequestId:(NSString *)requestId
                         clientId:(NSString *)clientId
                           userId:(NSString *)userId
                           bearer:(NSString *)bearer
                           method:(NSString *)method
                              uri:(NSString *)uri
                     kmsStaticKey:(NSString *)kmsStaticKey
                      clientEcKey:(NSString *)clientEcKey
                            error:(NSError **)error {
    
    cjose_err err;
    err.code = CJOSE_ERR_NONE;
    NSError *nserr;
    NSString *payload;
    
    char *cstrEcPubKey = NULL;
    cjose_header_t *hdr = NULL;
    cjose_jwe_t *jweRequest = NULL;

    // initialize the base class
    self = [super initWithRequestId:requestId
                           clientId:clientId
                             userId:userId
                             bearer:bearer
                             method:method
                                uri:uri
                              error:&nserr];
    if (nil == self) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // check for required KMS public static and client ephemeral EC keys
    if ((nil == kmsStaticKey) || (nil == clientEcKey)) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // import the static public kms key as a jwk
    if (nil == nserr) {
        self.jwkKmsStaticKey = cjose_jwk_import([kmsStaticKey UTF8String],
                                                [kmsStaticKey length],
                                                &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // import the EC key pair as a jwk
    if (nil == nserr) {
        self.jwkEcKey = cjose_jwk_import([clientEcKey UTF8String],
                                         [clientEcKey length],
                                         &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // export JSON representation of just the public part of the EC key pair
    if (nil == nserr) {
        cstrEcPubKey = cjose_jwk_to_json(self.jwkEcKey, false, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // create JWE header
    if (nil == nserr) {
        hdr = cjose_header_new(&err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // set alg on JWE to RSA-OAEP
    if (nil == nserr) {
        cjose_header_set(hdr, CJOSE_HDR_ALG, CJOSE_HDR_ALG_RSA_OAEP, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // set enc on JWE to A256GCM
    if (nil == nserr) {
        cjose_header_set(hdr, CJOSE_HDR_ENC, CJOSE_HDR_ENC_A256GCM, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // wrap the request payload in a JWE signed with the KMS static public key
    if (nil == nserr) {
        self.additionalAttributes = @{ @"jwk" : [NSJSONSerialization JSONObjectWithData:[[NSString stringWithCString:cstrEcPubKey encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] ?: @{} };
        payload = [self serialize];

        jweRequest = cjose_jwe_encrypt(self.jwkKmsStaticKey,
                                       hdr,
                                       (uint8_t *)[payload UTF8String],
                                       [payload length],
                                       &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // export encrypted JWE in compact serialized form and set message property
    if (nil == nserr) {
        char * cstrRequest = cjose_jwe_export(jweRequest, &err);
        if (nil != cstrRequest) {
            self.message = [[NSString alloc] initWithBytesNoCopy:cstrRequest
                                                          length:strlen(cstrRequest)
                                                        encoding:NSUTF8StringEncoding
                                                    freeWhenDone:YES];
        }
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // cleanup
    free(cstrEcPubKey);
    cjose_header_release(hdr);
    cjose_jwe_release(jweRequest);
    
    // error handling
    if (nil != nserr) {
        self = nil;
        if (error) {
            *error = nserr;
        }
    }

    return self;
}

- (instancetype)initWithRequestMessage:(NSString *)message
                          kmsStaticKey:(NSString *)kmsStaticKey
                                 error:(NSError **)error {
    cjose_err err;
    err.code = CJOSE_ERR_NONE;
    NSError *nserr;

    NSData *dataMessagePayload;
    id dictMessagePayload;
    
    cjose_jwe_t *jweMessage = NULL;

    // initialize the base class
    self = [super init];
    if (nil == self) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }

    // check for invalid args
    if (nil == nserr) {
        if (nil == message || nil == kmsStaticKey) {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }

    // import the client request to a jwe
    if (nil == nserr) {
        jweMessage = cjose_jwe_import([message UTF8String],
                                      [message length],
                                      &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // import the kms public/private key pair to a jwk
    if (nil == nserr) {
        self.jwkKmsStaticKey = cjose_jwk_import([kmsStaticKey UTF8String],
                                                [kmsStaticKey length],
                                                &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // decrypt the request using the kms private key
    if (nil == nserr) {
        size_t cstrMessagePayloadLen = 0;
        uint8_t *cstrMessagePayload = cjose_jwe_decrypt(jweMessage,
                                                        self.jwkKmsStaticKey,
                                                        &cstrMessagePayloadLen,
                                                        &err);
        if (nil != cstrMessagePayload) {
            dataMessagePayload = [NSData dataWithBytesNoCopy:cstrMessagePayload
                                                      length:cstrMessagePayloadLen
                                                freeWhenDone:YES];
            if (nil == dataMessagePayload) {
                CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            }
        }
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // deserialize and parse request payload to object properties
    if (nil == nserr) {
        dictMessagePayload = [NSJSONSerialization JSONObjectWithData:dataMessagePayload
                                                             options:0
                                                               error:&nserr];
        if (nil != dictMessagePayload) {
            [self setFromDictionary:dictMessagePayload error:&nserr];
        }
        else {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    
    // cleanup
    cjose_jwe_release(jweMessage);
    
    // error handling
    if (nil != nserr) {
        self = nil;
        if (error) {
            *error = nserr;
        }
    }
    
    return self;
}

- (void)dealloc {
    cjose_jwk_release(self.jwkKmsStaticKey);
    cjose_jwk_release(self.jwkEcKey);
}

- (BOOL)setFromDictionary:(NSDictionary *)root error:(NSError **)error {
    
    NSDictionary *client = [root typesafeObjectForKey:@"client"
                                                class:[NSDictionary class]];
    if (nil == client) {
        return NO;
    }
    
    NSDictionary *credential = [client typesafeObjectForKey:@"credential"
                                                      class:[NSDictionary class]];
    if (nil == credential) {
        return NO;
    }
    
    self.clientId = [client typesafeObjectForKey:@"clientId"
                                           class:[NSString class]];
    
    self.userId = [credential typesafeObjectForKey:@"userId"
                                             class:[NSString class]];
    
    self.bearer = [credential typesafeObjectForKey:@"bearer"
                                             class:[NSString class]];
    
    self.method = [root typesafeObjectForKey:@"method"
                                       class:[NSString class]];
    
    self.uri = [root typesafeObjectForKey:@"uri"
                                            class:[NSString class]];
    
    NSNumber *sequence = [root typesafeObjectForKey:@"sequence"
                                              class:[NSNumber class]];
    if (nil != sequence) {
        self.sequence = [sequence unsignedIntegerValue];
    }
    
    NSDictionary *dictJwk = [root typesafeObjectForKey:@"jwk"
                                                 class:[NSDictionary class]];
    
    // need to re-serialize to json so it can be imported as a jwk ;p
    NSData *dataJwk = [NSJSONSerialization dataWithJSONObject:dictJwk
                                                      options:0
                                                        error:error];
    
    cjose_err err;
    self.jwkEcKey = cjose_jwk_import([dataJwk bytes], [dataJwk length], &err);
    if (nil == self.jwkEcKey && nil != error) {
        *error = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    return (nil != self.clientId &&
            nil != self.userId &&
            nil != self.bearer &&
            nil != self.method &&
            nil != self.uri &&
            nil != sequence &&
            NULL != self.jwkEcKey);
}

@end
