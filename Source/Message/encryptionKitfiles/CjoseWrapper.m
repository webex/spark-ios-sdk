#import "CjoseWrapper+Private.h"
#import <cjose/header.h>
#import <cjose/jws.h>
#import <cjose/version.h>
#import <cjose/jwk.h>
#import <cjose/base64.h>
#import <cjose/jwe.h>




@implementation CjoseWrapper

+ (NSString *)ciphertextFromContent:(NSData *)content key:(NSString *)jwk error:(NSError **)error {
    cjose_err err;
    err.code = CJOSE_ERR_NONE;
    NSString *ciphertext;
    
    const uint8_t *octContent = (uint8_t *)[content bytes];
    const char *cstrJwkContentKey = [jwk UTF8String];
    
    // check inputs
    if ( NULL == octContent || NULL == cstrJwkContentKey) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
    }
    
    // import the jwk
    cjose_jwk_t *jwkContentKey = NULL;
    if (err.code == CJOSE_ERR_NONE) {
        jwkContentKey = cjose_jwk_import(cstrJwkContentKey,
                                         strlen(cstrJwkContentKey),
                                         &err);
    }
    
    // create header for jwe
    cjose_header_t *hdr = NULL;
    if (err.code == CJOSE_ERR_NONE) {
        hdr = cjose_header_new(&err);
    }
    
    // use alg = dir
    if (err.code == CJOSE_ERR_NONE) {
        cjose_header_set(hdr, CJOSE_HDR_ALG, CJOSE_HDR_ALG_DIR, &err);
    }
    
    // use enc = A256GCM
    if (err.code == CJOSE_ERR_NONE) {
        cjose_header_set(hdr, CJOSE_HDR_ENC, CJOSE_HDR_ENC_A256GCM, &err);
    }
    
    // create the JWE object
    cjose_jwe_t *jweContent = NULL;
    if (err.code == CJOSE_ERR_NONE) {
        size_t octContentLen = [content length];
        jweContent = cjose_jwe_encrypt(jwkContentKey,
                                       hdr,
                                       octContent,
                                       octContentLen,
                                       &err);
    }
    
    // export the JWE as compact serialization
    char *cstrJweContent = NULL;
    if (err.code == CJOSE_ERR_NONE) {
        cstrJweContent = cjose_jwe_export(jweContent, &err);
    }
    
    // cleanup
    cjose_jwk_release(jwkContentKey);
    cjose_header_release(hdr);
    cjose_jwe_release(jweContent);
    
    // set return value
    if (err.code == CJOSE_ERR_NONE) {
        ciphertext = [[NSString alloc] initWithBytesNoCopy:cstrJweContent
                                                    length:strlen(cstrJweContent)
                                                  encoding:NSUTF8StringEncoding
                                              freeWhenDone:YES];
    }
    else {
        free(cstrJweContent);
        if (error) {
            (*error) = [self errorWithCjoseErr:&err];
        }
    }
    
    return ciphertext;
}

+ (NSData *)contentFromCiphertext:(NSString *)ciphertext key:(NSString *)jwk error:(NSError **)error {
    cjose_err err;
    err.code = CJOSE_ERR_NONE;
    NSData *cleartext;
    
    const char *cstrJwkContentKey = [jwk UTF8String];
    const char *cstrJweContent = [ciphertext UTF8String];
    
    // check inputs
    if (NULL == cstrJwkContentKey || NULL == cstrJweContent) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
    }
    
    // import the jwk
    cjose_jwk_t *jwkContentKey = NULL;
    if (err.code == CJOSE_ERR_NONE) {
        jwkContentKey = cjose_jwk_import(cstrJwkContentKey,
                                         strlen(cstrJwkContentKey),
                                         &err);
    }
    
    // import the jwe
    cjose_jwe_t *jweContent = NULL;
    if (err.code == CJOSE_ERR_NONE) {
        jweContent = cjose_jwe_import(cstrJweContent,
                                      strlen(cstrJweContent),
                                      &err);
    }
    
    
    // decrypt the imported jwe
    uint8_t *cstrContent = NULL;
    size_t cstrContentLen = 0;
    if (err.code == CJOSE_ERR_NONE) {
        cstrContent = cjose_jwe_decrypt(jweContent,
                                        jwkContentKey,
                                        &cstrContentLen,
                                        &err);
    }
    
    // cleanup
    cjose_jwk_release(jwkContentKey);
    cjose_jwe_release(jweContent);
    
    // set return value
    if (err.code == CJOSE_ERR_NONE) {
        cleartext = [NSData dataWithBytesNoCopy:cstrContent
                                         length:cstrContentLen
                                   freeWhenDone:YES];
    }
    else {
        free(cstrContent);
        if (error) {
            (*error) = [self errorWithCjoseErr:&err];
        }
    }
    
    return cleartext;
}

+ (NSString *)jwkFromKeyValue:(id)keyValue error:(NSError **)error {
    if (![keyValue isKindOfClass:[NSString class]]) {
        if (![NSJSONSerialization isValidJSONObject:keyValue]) {
            return nil;
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:keyValue
                                                       options:0 error:error];
        if (!data) {
            return nil;
        }
        
        keyValue = [[NSString alloc] initWithData:data
                                         encoding:NSUTF8StringEncoding];
    }
    
    cjose_err err;
    cjose_jwk_t *jwk = cjose_jwk_import([keyValue UTF8String],
                                        [keyValue length],
                                        &err);
    if (jwk) {
        cjose_jwk_release(jwk);
        return keyValue;
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    char byte_chars[3] = {'\0', '\0', '\0'};
    for (NSUInteger index = 0; index < [keyValue length]; index += 2) {
        byte_chars[0] = [keyValue characterAtIndex:index];
        byte_chars[1] = [keyValue characterAtIndex:(index + 1)];
        unsigned char whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    jwk = cjose_jwk_create_oct_spec([data bytes], [data length], &err);
    if (!jwk) {
        if (error) {
            (*error) = [self errorWithCjoseErr:&err];
        }
        return nil;
    }
    
    NSString *jwkString;
    char *json = cjose_jwk_to_json(jwk, true, &err);
    if (json) {
        jwkString = [NSString stringWithUTF8String:json];
    } else {
        if (error) {
            (*error) = [self errorWithCjoseErr:&err];
        }
    }
    
    cjose_jwk_release(jwk);
    return jwkString;
}

+ (NSString *)base64URLEncodedStringFromData:(NSData *)data error:(NSError **)error {
    cjose_err err;
    
    char *cstr_B64u = NULL;
    size_t cstr_B64u_len = 0;
    
    if (!cjose_base64url_encode(data.bytes,
                                data.length,
                                &cstr_B64u,
                                &cstr_B64u_len,
                                &err)) {
        if (error) {
            (*error) = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    
    NSString *b64u = [[NSString alloc] initWithBytesNoCopy:cstr_B64u
                                                    length:cstr_B64u_len
                                                  encoding:NSUTF8StringEncoding
                                              freeWhenDone:YES];
    return b64u;
}

+ (NSData *)dataFromBase64URLEncodedString:(NSString *)b64u error:(NSError **)error {
    cjose_err err;
    
    uint8_t *ui_data = NULL;
    size_t ui_data_len = 0;
    
    if (!cjose_base64url_decode(b64u.UTF8String,
                                b64u.length,
                                &ui_data,
                                &ui_data_len,
                                &err)) {
        if (error) {
            (*error) = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBytesNoCopy:ui_data
                                                length:ui_data_len
                                          freeWhenDone:YES];
    
    return data;
}

+ (NSString *)kmsStaticKeyFromJwkString:(NSString *)jwkString {
    char *json = cjose_jwk_to_json(cjose_jwk_import(jwkString.UTF8String, jwkString.length, NULL), true, NULL);
    return json ? [[NSString alloc] initWithBytesNoCopy:json length:strlen(json) encoding:NSUTF8StringEncoding freeWhenDone:YES] : nil;
}

+ (NSString *)kmsStaticPublicKeyFromJwkString:(NSString *)jwkString {
    char *json = cjose_jwk_to_json(cjose_jwk_import(jwkString.UTF8String, jwkString.length, NULL), false, NULL);
    return json ? [[NSString alloc] initWithBytesNoCopy:json length:strlen(json) encoding:NSUTF8StringEncoding freeWhenDone:YES] : nil;
}

@end

@implementation CjoseWrapper (Private)

+ (NSError *)errorWithCjoseErr:(cjose_err *)err {
    if (!err || err->code == CJOSE_ERR_NONE) {
        return nil;
    }
    
    NSDictionary *userInfo = @{ @"message": [NSString stringWithUTF8String:err->message],
                                @"function": [NSString stringWithUTF8String:err->function],
                                @"file": [NSString stringWithUTF8String:err->file],
                                @"line": @(err->line) };
    return [NSError errorWithDomain:@"cJose" code:err->code userInfo:userInfo];
}

@end
