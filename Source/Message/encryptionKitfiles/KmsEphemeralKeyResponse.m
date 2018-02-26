#import "KmsEphemeralKeyResponse.h"

#import "CjoseWrapper+Private.h"
#import "KmsEphemeralKeyRequest+Private.h"
#import "KmsKey.h"
#import "NSDictionary+Extensions.h"
#import "SparkSDK/SparkSDK-Swift.h"

@interface KmsEphemeralKeyResponse ()

@property (nonatomic, readwrite) KmsKey *ecKey;
@property (nonatomic, readwrite) cjose_jwk_t *jwkEcKey;
@property (nonatomic, readwrite) cjose_jws_t *jwsResponse;
@property (nonatomic, readwrite) NSUInteger sequence;
@property (nonatomic, readwrite) NSUInteger status;
@property (nonatomic, readwrite) NSString *reason;
@property (nonatomic, readwrite) NSString *message;
@property (nonatomic, readwrite) NSString *jwkEphemeralKey;
@property (nonatomic, readwrite) NSString *requestId;
@property (nonatomic, readwrite) NSDate *expirationDate;

@end

@implementation KmsEphemeralKeyResponse

@synthesize sequence = _sequence;
@synthesize status = _status;
@synthesize reason = _reason;
@synthesize message = _message;
@synthesize jwkEphemeralKey = _jwkEphemeralKey;

- (instancetype)initWithMessage:(NSString *)message jwkEphemeralKey:(NSString *)jwkEphemeralKey requestId:(NSString *)requestId expirationDate:(NSDate *)expirationDate {
    self = [super init];
    if (self) {
        _message = message;
        _jwkEphemeralKey = jwkEphemeralKey;
        _requestId = requestId;
        _expirationDate = expirationDate;
    }
    return self;
}

- (instancetype)initWithResponseMessage:(NSString *)message
                                request:(KmsEphemeralKeyRequest *)request
                                  error:(NSError **)error {
    cjose_err err;
    err.code = CJOSE_ERR_NONE;
    NSError *nserr;

    NSData *dataPayload;
    id dictPayload;
    cjose_jwk_t *jwk = NULL;

    // initialize the base class
    self = [super init];
    if (nil == self) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // check for invalid args
    if (nil == nserr) {
        if (nil == message || nil == request) {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    self.message = message;

    // import the kms response message as a jws
    if (nil == nserr) {
        self.jwsResponse = cjose_jws_import([message UTF8String],
                                            [message length],
                                            &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // verify the response signature
    if (nil == nserr) {
        if (!cjose_jws_verify(self.jwsResponse, request.jwkKmsStaticKey, &err)) {
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    
    // extract response payload (note: jws object owns the plaintext buffer)
    if (nil == nserr) {
        size_t cstrMessagePayloadLen = 0;
        uint8_t *cstrMessagePayload = NULL;
        cjose_jws_get_plaintext(self.jwsResponse,
                                &cstrMessagePayload,
                                &cstrMessagePayloadLen,
                                &err);
        if (nil != cstrMessagePayload) {
            dataPayload = [NSData dataWithBytesNoCopy:cstrMessagePayload
                                               length:cstrMessagePayloadLen
                                         freeWhenDone:NO];
            if (nil == dataPayload) {
                CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            }
        }
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // deserialize and parse response payload to object properties
    if (nil == nserr) {
        dictPayload = [NSJSONSerialization JSONObjectWithData:dataPayload
                                                      options:0
                                                        error:&nserr];
        if (nil != dictPayload) {
            [self setFromDictionary:dictPayload error:&nserr];
        }
        else {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }

    // import the jwk attribute of the response payload as the response EC key
    if (nil == nserr) {
        self.jwkEcKey = cjose_jwk_import([self.ecKey.jwk UTF8String],
                                         [self.ecKey.jwk length],
                                         &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // generate DH ephemeral key
    if (nil == nserr) {
        jwk = cjose_jwk_derive_ecdh_ephemeral_key(request.jwkEcKey,
                                                  self.jwkEcKey,
                                                  &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // set the kid on the DH ephemeral key
    if (nil == nserr) {
        cjose_jwk_set_kid(jwk,
                          [self.ecKey.uri UTF8String],
                          [self.ecKey.uri length],
                          &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // serialize the DH ephemeral key
    if (nil == nserr) {
        char *cstr = cjose_jwk_to_json(jwk, true, &err);
        if (nil != cstr) {
            self.jwkEphemeralKey = [[NSString alloc] initWithBytesNoCopy:cstr
                                                                  length:strlen(cstr)
                                                                encoding:NSUTF8StringEncoding
                                                            freeWhenDone:YES];
        }
        else {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    
    // cleanup
    cjose_jwk_release(jwk);
    
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
    
    KmsEphemeralKeyRequest *request;
    NSString *uri;
    NSString *createDate;
    NSString *expirationDate;
    NSString *strKmsEcPubKey;
    NSString *payload;
    cjose_jwk_t *jwk = NULL;
 
    cjose_header_t *hdr = NULL;
    
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
    
    // decrypt and parse the request message
    if (nil == nserr) {
        request = [[KmsEphemeralKeyRequest alloc] initWithRequestMessage:message
                                                            kmsStaticKey:kmsStaticKey
                                                                   error:error];
        if (nil == request) {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    
    // create a KMS-side ephemeral EC key pair as a jwk
    if (nil == nserr) {
        self.jwkEcKey = cjose_jwk_create_EC_random(CJOSE_JWK_EC_P_256, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }

    // export JSON representation of only public part of the EC key pair
    if (nil == nserr) {
        char *cstrKmsEcPubKey = cjose_jwk_to_json(self.jwkEcKey, false, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
        if (nil != cstrKmsEcPubKey) {
            strKmsEcPubKey = [[NSString alloc] initWithBytesNoCopy:cstrKmsEcPubKey
                                                            length:strlen(cstrKmsEcPubKey)
                                                          encoding:NSUTF8StringEncoding
                                                      freeWhenDone:YES];
        }
    }
    
    // generate ephemeral key uri
    if (nil == nserr) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *strUuid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        if (nil != strUuid) {
            uri = [request.uri stringByAppendingFormat:@"/%@", strUuid];
        }
        else {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    
    // generate createDate and expirationDate as strings in RFC-3339 date-format
    if (nil == nserr) {
        createDate = [NSDateFormatter stringFromIso8601WithMillisecondsDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        expirationDate = [NSDateFormatter stringFromIso8601WithMillisecondsDate:[NSDate dateWithTimeIntervalSinceNow:3600]];
        
        if (nil == createDate || nil == expirationDate) {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    
    // create the key
    self.ecKey = [[KmsKey alloc] initWithUri:uri
                                      userId:request.userId
                                    clientId:request.clientId
                                  createDate:createDate
                              expirationDate:expirationDate
                                         jwk:strKmsEcPubKey
                                       error:error];
    
    // create JWS header
    if (nil == nserr) {
        hdr = cjose_header_new(&err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // set alg on JWS to CJOSE_HDR_ALG_PS256
    if (nil == nserr) {
        cjose_header_set(hdr, CJOSE_HDR_ALG, CJOSE_HDR_ALG_PS256, &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // wrap the response payload in a JWS signed by the KMS private static key
    if (nil == nserr) {
        payload = [self serializeWithAdditionalAttributes:
                   @{ @"key" : self.ecKey.dictionaryRepresentation ?: @{} }];
        
        cjose_jwk_t *jwk2 = cjose_jwk_import([kmsStaticKey UTF8String],
                                            [kmsStaticKey length],
                                            &err);
        if (nil != jwk2) {
            self.jwsResponse = cjose_jws_sign(jwk2,
                                              hdr,
                                              (uint8_t *)[payload UTF8String],
                                              [payload length],
                                              &err);
        }
        cjose_jwk_release(jwk2);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // export the signed JWS in compact serialied form (note: jwsResponse owns the cstr)
    if (nil == nserr) {
        const char *cstrResponse = NULL;
        if (cjose_jws_export(self.jwsResponse, &cstrResponse, &err)) {
            self.message = [[NSString alloc] initWithBytesNoCopy:(void *)cstrResponse
                                                          length:strlen(cstrResponse)
                                                        encoding:NSUTF8StringEncoding
                                                    freeWhenDone:NO];
            if (nil == self.message) {
                CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            }
        }
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // generate DH ephemeral key
    if (nil == nserr) {
        jwk = cjose_jwk_derive_ecdh_ephemeral_key(self.jwkEcKey,
                                                  request.jwkEcKey,
                                                  &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // set the kid on the DH ephemeral key
    if (nil == nserr) {
        cjose_jwk_set_kid(jwk, [uri UTF8String], [uri length], &err);
        nserr = [CjoseWrapper errorWithCjoseErr:&err];
    }
    
    // serialize the DH ephemeral key
    if (nil == nserr) {
        char *cstr = cjose_jwk_to_json(jwk, true, &err);
        if (nil != cstr) {
            self.jwkEphemeralKey = [[NSString alloc] initWithBytesNoCopy:cstr
                                                                  length:strlen(cstr)
                                                                encoding:NSUTF8StringEncoding
                                                            freeWhenDone:YES];
        }
        else {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            nserr = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    
    // cleanup
    cjose_header_release(hdr);
    cjose_jwk_release(jwk);
    
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
    cjose_jwk_release(self.jwkEcKey);
    cjose_jws_release(self.jwsResponse);
}

- (BOOL)setFromDictionary:(NSDictionary *)root error:(NSError **)error {
    
    NSNumber *status = [root typesafeObjectForKey:@"status"
                                            class:[NSNumber class]];
    if (nil != status) {
        self.status = [status unsignedIntegerValue];
    }
    
    NSNumber *sequence = [root typesafeObjectForKey:@"sequence"
                                              class:[NSNumber class]];
    if (nil != sequence) {
        self.sequence = [sequence unsignedIntegerValue];
    }
    
    NSString *requestId = [root typesafeObjectForKey:@"requestId"
                                               class:[NSString class]];
    if (nil != requestId) {
        self.requestId = requestId;
    }

    self.reason = [root typesafeObjectForKey:@"reason"
                                       class:[NSString class]];
    
    NSDictionary *key = [root typesafeObjectForKey:@"key"
                                             class:[NSDictionary class]];
    
    self.ecKey = [[KmsKey alloc] initFromDictionary:key error:error];
    
    self.expirationDate = [NSDateFormatter dateFromIso8601WithMillisecondsString:self.ecKey.expirationDate];
    
    return (nil != status &&
            nil != sequence &&
            nil != self.ecKey);
}

@end
