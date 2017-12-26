#import <Foundation/Foundation.h>

@interface CjoseWrapper : NSObject

/**
 cJose helper function for symmetric encryption.
 \param content The data to be encrypted.
 \param jwk A JOSE JWK representation of a symmetric key.
 \returns a JOSE JWE compact serialization of the data as encrypted with the 
      given key, or NULL if an error has occurred.  In the event of an error, 
      the caller may get additional information regarding the failure from the 
      nsError property.
*/
+ (NSString *)ciphertextFromContent:(NSData *)content
                                key:(NSString *)jwk
                              error:(NSError **)error;

/**
 cJose helper function for symmetric decryption.
 \param cihpertext The data to be decrypted, presented as a JWE compact s11n.
 \param jwk A JOSE JWK representation of a symmetric key.
 \returns decrypted contents from the given JWE as decoded with the given JWK 
      key, or NULL if an error has occurred.  In the event of an error, the 
      caller may get additional information regarding the failure from the 
      nsError property.
 */
+ (NSData *)contentFromCiphertext:(NSString *)ciphertext
                              key:(NSString *)jwk
                            error:(NSError **)error;

/**
 cJose helper function for encoding raw data provided in an NSData to a
 base64url encoded NSString.
 \param data The data to be encoded.
 \returns a Base64url encoding of the given data.
 */
+ (NSString *)base64URLEncodedStringFromData:(NSData *)data
                                       error:(NSError **)error;

/**
 cJose helper function for decoding raw data provided in an NSData to a
 base64url encoded NSString.
 \param data The data to be encoded.
 \returns a Base64url encoding of the given data.
 */
+ (NSData *)dataFromBase64URLEncodedString:(NSString *)b64u
                                     error:(NSError **)error;

/**
 Validate a key value and try to provide a jwk.
 FIXME: We should probably evolve this to be just a validate function and 
 let the caller handle the error flow.
 */
+ (NSString *)jwkFromKeyValue:(id)keyValue error:(NSError **)error;

/** These are currently used for test. */
+ (NSString *)kmsStaticKeyFromJwkString:(NSString *)jwkString;
+ (NSString *)kmsStaticPublicKeyFromJwkString:(NSString *)jwkString;


@end
