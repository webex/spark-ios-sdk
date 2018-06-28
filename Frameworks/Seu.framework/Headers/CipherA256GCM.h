#import <Foundation/Foundation.h>

@class SecureContentReference;

/**
 The CipherA256GCM is used by the SecureInputStream and SecureOutputStream
 classes to actually perform cryptographic operation.  The intent is to 
 consolidate these operations behind a simple API which will (ultimately)
 be used as a common interface for multiple scheme implementations, such
 that they can be used concurrently and selected dynamically as needed.
 */
@interface CipherA256GCM : NSObject

@property (nonatomic, readonly) size_t blockSize;

/**
 Initialize the cipher based on the given secure content reference.
 
 \param scr The secure content reference on which the cipher will be 
            initialized.  Note, if the SCR has a non-zero length MAC tag the
            cipher will automatically be put into decrypt mode.  Otherwise it
            will be put into encrypt mode.
 \returns   The initialiezd cipher instance.
 */
- (instancetype)initWithSecureContentReference:(SecureContentReference *)scr
                                         error:(NSError **)error;

/**
 Encrypts bytes from a read buffer to a write buffer.  This may be invoked 
 only when the cipher is in encrypt mode.
 
 \param rbuf   The buffer containing cleartext bytes to be encrypted.
 \param wbuf   The buffer to which ciphertext bytes are to be written.
 \param length The number of bytes to be encrypted.  Caller is responsible for
               ensuring that both rbuf and wbuf are at least this many bytes
               long.
 \returns      The number of bytes actually encrypted, or -1 on error.
 */
- (NSInteger)encryptBytes:(const uint8_t *)rbuf
                 toBuffer:(uint8_t *)wbuf
               withLength:(size_t)length
                    error:(NSError **)error;

/**
 Decrypts bytes from a read buffer to a write buffer. This may be invoked
 only when the cipher is in decrypt mode.

 
 \param rbuf   The buffer containing cihpertext bytes to be decrypted.
 \param wbuf   The buffer to which cleartext bytes are to be written.
 \param length The number of bytes to be decrypted.  Caller is responsible for
               ensuring that both rbuf and wbuf are at least this many bytes
               long.
 \returns      The number of bytes actually decrypted, or -1 on error.
 */
- (NSInteger)decryptBytes:(const uint8_t *)rbuf
                 toBuffer:(uint8_t *)wbuf
               withLength:(size_t)length
                    error:(NSError **)error;

/**
 Performs encipher/decipher finalization.  For a cipher in encrypt mode this
 will involve computation of the GCM tag and provisioning of the SCR with the
 computed MAC.  For a cipher in decrypt mode this will involve validation of the 
 GCM tag provided in the SCR with that computed during decryption.
 
 \returns True if successful, and in the case of decrypt mode the computed
          GCM tag matches that given in the SCR.  Otherwise false.
 */
- (BOOL)finalizeWithError:(NSError **)error;

@end
