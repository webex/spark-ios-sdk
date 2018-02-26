#import "SecureContentReference.h"

#import "CjoseWrapper+Private.h"
#import "SparkSDK/SparkSDK-Swift.h"


@implementation SecureContentReference

+ (instancetype)secureContentReferenceWithError:(NSError **)error {
    
    // set the encrypting algorithm
    NSString *enc = @"A256GCM";
    
    // generate a random 256 bit key
    size_t key_len = 32;
    uint8_t ui_key[key_len];
    if (-1 == SecRandomCopyBytes(kSecRandomDefault, key_len, ui_key)) {
        if (nil != error) {
            NSDictionary *userInfo = @{ @"message": @"Failed to generate random key." };
            *error = [NSError errorWithDomain:@"SCR" code:errno userInfo:userInfo];
        }
        return nil;
    }
    NSData *key = [[NSData alloc] initWithBytes:ui_key length:key_len];
    
    // generate a random 96 bit initialization vector
    size_t iv_len = 12;
    uint8_t ui_iv[iv_len];
    if (-1 == SecRandomCopyBytes(kSecRandomDefault, iv_len, ui_iv)) {
        if (nil != error) {
            NSDictionary *userInfo = @{ @"message": @"Failed to generate random iv." };
            *error = [NSError errorWithDomain:@"SCR" code:0 userInfo:userInfo];
        }
        return nil;
    }
    NSData *iv = [[NSData alloc] initWithBytes:ui_iv length:iv_len];
    
    // generate the current date and time as iso-date-time, UTC timezone
    NSString *aad = [NSDateFormatter stringFromIso8601WithMillisecondsDate:[[NSDate alloc] init]];
    
    // return a new SCR
    return [[SecureContentReference alloc] initWithEnc:enc key:key iv:iv aad:aad loc:nil tag:nil];
}

- (NSString *)jsonWithError:(NSError **)error {
    // don't generate useless SCR serializations
    if (nil == self.enc || nil == self.key || nil == self.iv || nil == self.aad || nil == self.loc || nil == self.tag) {
        if (nil != error) {
            NSDictionary *userInfo = @{ @"message": @"Cannot serialize incomplete SCR object." };
            *error = [NSError errorWithDomain:@"SCR" code:0 userInfo:userInfo];
        }
        return nil;
    }
    
    NSString *b64u_key = [CjoseWrapper base64URLEncodedStringFromData:self.key error:error];
    if (nil == b64u_key) {
        return nil;
    }
    
    NSString *b64u_iv = [CjoseWrapper base64URLEncodedStringFromData:self.iv error:error];
    if (nil == b64u_iv) {
        return nil;
    }

    NSString *b64u_tag = [CjoseWrapper base64URLEncodedStringFromData:self.tag error:error];
    if (nil == b64u_tag) {
        return nil;
    }

    NSString *scr = [[NSString alloc] initWithFormat:
                     @"{"
                        "\"enc\": \"%@\","
                        "\"key\": \"%@\","
                        "\"iv\": \"%@\","
                        "\"aad\": \"%@\","
                        "\"loc\": \"%@\","
                        "\"tag\": \"%@\""
                     "}",
                     self.enc, b64u_key, b64u_iv, self.aad, self.loc, b64u_tag];
    
    return scr;
}

- (NSString *)encryptedSecureContentReferenceWithKey:(NSString *)jwk error:(NSError **)error {
    // get the plaintext serialization of this SCR
    NSString *nss_scr = [self jsonWithError:error];
    if (nil == nss_scr) {
        return nil;
    }
    
    // convert the NSString to NSData for consumption by the encryption alg
    NSData *nsd_scr = [nss_scr dataUsingEncoding:NSUTF8StringEncoding];
    if (nil == nsd_scr) {
        if (nil != error) {
            NSDictionary *userInfo = @{ @"message": @"Failed to convert SCR string to data object." };
            *error = [NSError errorWithDomain:@"SCR" code:0 userInfo:userInfo];
        }
        return nil;
    }
    
    // return a JWE containing the SCR encrypted with the given jwk.
    return [CjoseWrapper ciphertextFromContent:nsd_scr key:jwk error:error];
}

+ (instancetype)decryptedSecureContentReferenceFromJWE:(NSString *)jwe key:(NSString *)jwk error:(NSError **)error {
    // decrypt the JWE using the given key
    if (!jwe || !jwk) {
        return nil;
    }
    
    NSData *nsd_scr = [CjoseWrapper contentFromCiphertext:jwe key:jwk error:error];
    if (nil == nsd_scr) {
        return nil;
    }

    // convert the cleartext from NSData to NSString
    id obj = [NSJSONSerialization JSONObjectWithData:nsd_scr options:0 error:error];
    if (nil == obj || ![obj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [self secureContentReferenceWithDictionary:obj error:error];
}

+ (instancetype)secureContentReferenceWithJson:(NSString *)json error:(NSError **)error {
    id obj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:error];
    if (nil == obj || ![obj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [self secureContentReferenceWithDictionary:obj error:error];
}

+ (instancetype)secureContentReferenceWithDictionary:(NSDictionary *)dict error:(NSError **)error {
    // extract enc
    NSString *enc = [SecureContentReference stringAttribute:@"enc" fromDictionary:dict];
    if (nil == enc) {
        return nil;
    }
    
    // extract and decode key
    NSData *key = [SecureContentReference dataAttribute:@"key" fromDictionary:dict error:error];
    if (nil == key) {
        return nil;
    }

    // extract and decode iv
    NSData *iv = [SecureContentReference dataAttribute:@"iv" fromDictionary:dict error:error];
    if (nil == iv) {
        return nil;
    }
    
    // extract aad
    NSString *aad = [SecureContentReference stringAttribute:@"aad" fromDictionary:dict];
    if (nil == aad) {
        return nil;
    }

    // extract loc (and convert to URL)
    NSString *str_loc = [SecureContentReference stringAttribute:@"loc" fromDictionary:dict];
    if (nil == str_loc) {
        return nil;
    }
    NSURL *loc = [[NSURL alloc] initWithString:str_loc];
    if (nil == loc) {
        return nil;
    }

    // extract and decode iv
    NSData *tag = [SecureContentReference dataAttribute:@"tag" fromDictionary:dict error:error];
    if (nil == tag) {
        return nil;
    }

    // return a new SCR
    return [[SecureContentReference alloc] initWithEnc:enc key:key iv:iv aad:aad loc:loc tag:tag];
}

#pragma mark - Private

- (instancetype)initWithEnc:(NSString *)enc
                        key:(NSData *)key
                        iv:(NSData *)iv
                        aad:(NSString *)aad
                        loc:(NSURL *)loc
                        tag:(NSData *)tag  {
    self = [super init];
    if (self) {
        _enc = enc;
        _key = key;
        _iv = iv;
        _aad = aad;
        _loc = loc;
        _tag = tag;
    }
    return self;
}

+ (NSString *)stringAttribute:(NSString *)key fromDictionary:(NSDictionary *)dict {
    NSObject *obj = dict[key];
    if (nil == obj || ![obj isKindOfClass:[NSString class]] || [(NSString *)obj length] == 0) {
        return nil;
    }
    return (NSString *)obj;
}

+ (NSData *)dataAttribute:(NSString *)key fromDictionary:(NSDictionary *)dict error:(NSError **)error {
    NSString *b64u = [SecureContentReference stringAttribute:key fromDictionary:dict];
    if (nil == b64u) {
        return nil;
    }
    return [CjoseWrapper dataFromBase64URLEncodedString:(NSString *)b64u error:error];
}

@end
