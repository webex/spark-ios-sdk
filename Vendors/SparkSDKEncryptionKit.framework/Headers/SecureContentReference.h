#import <Foundation/Foundation.h>

/**
 This class represents a secure content reference (SCR) as described in the
 E2E specification.  It provides a means for generating, encapsulating, and
 securing the key and associated metadata required for encrypting and decrypting 
 content (to be) stored to a URL addressable location.
 */
@interface SecureContentReference : NSObject

/**
 A string name, as defined by JOSE, describing the content encryption algo. 
 */
@property (nonatomic, readonly) NSString *enc;

/**
 The key used for encrypting content.
 */
@property (nonatomic, readonly) NSData *key;

/**
 The initialization vector for encrypting content.
 */
@property (nonatomic, readonly) NSData *iv;

/**
 The additional authentication data used when encrypting content.
 */
@property (nonatomic, readonly) NSString *aad;

/**
 The location of the uploaded encrypted content.
 */
@property (nonatomic) NSURL *loc;

/**
 The GCM authentication tag resulting from content encryption.
 */
@property (nonatomic) NSData *tag;

/**
 Initializes a new SCR object, automatically setting the
 enc, key, iv, aad properties.
 */
+ (instancetype)secureContentReferenceWithError:(NSError **)error;

+ (instancetype)secureContentReferenceWithJson:(NSString *)json error:(NSError **)error;

/**
 Return this SCR's current state as a plaintext JSON serialization.
 */
- (NSString *)jsonWithError:(NSError **)error;

/**
 Produces a JWE compact serialization of this SCR, using the given
 key.  The key must be a JSON serialization of a standard JWK.
 \param jwk The key to use for encrypting the SCR.
 \returns The encrypted SCR in the form of a JWE compact serialization.
 */
- (NSString *)encryptedSecureContentReferenceWithKey:(NSString *)jwk error:(NSError **)error;

/**
 Produces a new SCR instance from a given JWE compact serialization,
 decrypting it with the given JWK.
 \param jwe A JWE compact serialization of an SCR.
 \param jwk The JWK to use for decrypting the JWE.
 \returns A decrypted SCR instance.
 */
+ (instancetype)decryptedSecureContentReferenceFromJWE:(NSString *)jwe key:(NSString *)jwk error:(NSError **)error;

@end
