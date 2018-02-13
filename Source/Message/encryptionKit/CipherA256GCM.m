#import "CipherA256GCM.h"

#import <openssl/evp.h>

#import "CjoseWrapper+Private.h"
#import "SecureContentReference.h"

typedef enum { ENCRYPTING = 0, DECRYPTING } CipherMode;

@interface CipherA256GCM ()
@property (nonatomic, readwrite) NSString *enc;
@property (nonatomic, readwrite) SecureContentReference *scr;
@property (nonatomic, readwrite) EVP_CIPHER_CTX *ctx;
@property (nonatomic, readwrite) CipherMode mode;
@end

@implementation CipherA256GCM

#pragma mark - Object Lifecycle Methods

- (instancetype)initWithSecureContentReference:(SecureContentReference *)scr error:(NSError **)error {
    cjose_err err;
    _blockSize = 32;
    
    // currently only support A256GCM scheme
    if (![scr.enc isEqualToString:@"A256GCM"]) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
        goto _initWithSecureContentReferenceFail;
    }

    // ensure the key is correct length
    if (32 != scr.key.length) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
        goto _initWithSecureContentReferenceFail;
    }

    // ensure the iv is correct length
    if (12 != scr.iv.length) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
        goto _initWithSecureContentReferenceFail;
    }

    // ensure the tag is less than MAX_INT since library
    // only supports 32bit
    if (scr.tag.length > INT_MAX) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
        goto _initWithSecureContentReferenceFail;
    }

    // initialize the base class
    self = [super init];
    if (nil == self) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
        goto _initWithSecureContentReferenceFail;
    }
    self.scr = scr;

    // instantiate and initialize the openssl context
    self.ctx = EVP_CIPHER_CTX_new();
    if (NULL == self.ctx) {
        CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
        goto _initWithSecureContentReferenceFail;
    }
    EVP_CIPHER_CTX_init(self.ctx);

    // get A256GCM cipher
    const EVP_CIPHER *cipher = EVP_aes_256_gcm();
    if (NULL == cipher) {
        CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
        goto _initWithSecureContentReferenceFail;
    }
    
    // if the scr has a tag - then prep the cipher for decrypt, otherwise encrypt
    if (0 < scr.tag.length) {
        self.mode = DECRYPTING;
        
        // prepare context for A256GCM decryption with key and iv
        if (EVP_DecryptInit_ex(self.ctx, cipher, 0, scr.key.bytes, scr.iv.bytes) != 1) {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _initWithSecureContentReferenceFail;
        }
        
        // set the GCM model authentication tag
        if (EVP_CIPHER_CTX_ctrl(self.ctx, EVP_CTRL_GCM_SET_TAG,
                                (int)scr.tag.length, (void *)scr.tag.bytes) != 1) {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _initWithSecureContentReferenceFail;
        }
        
        // set GCM mode AAD data
        int bytes_decrypted = 0;
        if (EVP_DecryptUpdate(self.ctx, 0, &bytes_decrypted,
                              (uint8_t *)scr.aad.UTF8String, (int)scr.aad.length) != 1 ||
            (unsigned int)bytes_decrypted != scr.aad.length) {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _initWithSecureContentReferenceFail;
        }
    }
    else
    {
        // the scr has no tag set, we must be encrypting
        self.mode = ENCRYPTING;

        // prepare context for A256GCM encryption with key and iv
        if (EVP_EncryptInit_ex(self.ctx, cipher, 0, scr.key.bytes, scr.iv.bytes) != 1) {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _initWithSecureContentReferenceFail;
        }
        
        // set GCM mode AAD data
        int bytes_encrypted = 0;
        if (EVP_EncryptUpdate(self.ctx, 0, &bytes_encrypted,
                              (uint8_t *)scr.aad.UTF8String, (int)scr.aad.length) != 1 ||
            (unsigned int)bytes_encrypted != scr.aad.length) {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _initWithSecureContentReferenceFail;
        }
    }
    
    return self;
    
_initWithSecureContentReferenceFail:
    
    if (nil != error) {
        *error = [CjoseWrapper errorWithCjoseErr:&err];
    }
    return nil;
}

-(void)dealloc {
    if (NULL != self.ctx) {
        EVP_CIPHER_CTX_free(self.ctx);
    }
}

#pragma mark - Public Methods

- (NSInteger)encryptBytes:(const uint8_t *)rbuf toBuffer:(uint8_t *)wbuf withLength:(size_t)length error:(NSError **)error {
    cjose_err err;
    int written = 0;
    
    // make sure the cipher is actually in encrypt mode
    if (ENCRYPTING != self.mode) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
        goto _encryptBlockFail;
    }
    
    // encrypt requested number of bytes from rbuf to wbuf
    if (EVP_EncryptUpdate(self.ctx, wbuf, &written, rbuf, (int)length) != 1) {
        CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
        goto _encryptBlockFail;
    }
    return written;

_encryptBlockFail:
    
    if (nil != error) {
        *error = [CjoseWrapper errorWithCjoseErr:&err];
    }
    return -1;
}

- (NSInteger)decryptBytes:(const uint8_t *)rbuf toBuffer:(uint8_t *)wbuf withLength:(size_t)length error:(NSError **)error {
    cjose_err err;
    int written = 0;
    
    // make sure the cipher is actually in decrypt mode
    if (DECRYPTING != self.mode) {
        CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
        goto _decryptBlockFail;
    }
    
    // decrypt requested number of bytes from rbuf to wbuf
    if (EVP_DecryptUpdate(self.ctx, wbuf, &written, rbuf, (int)length) != 1) {
        CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
        goto _decryptBlockFail;
    }
    return written;

_decryptBlockFail:
    
    if (nil != error) {
        *error = [CjoseWrapper errorWithCjoseErr:&err];
    }
    return -1;
}

- (BOOL)finalizeWithError:(NSError **)error {
    cjose_err err;
    int written = 0;
    
    if (ENCRYPTING == self.mode) {
        
        // finalize encryption and set the ciphertext length to correct value
        if (EVP_EncryptFinal_ex(self.ctx, 0, &written) != 1)
        {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _finalizeWithErrorFail;
        }
        
        // get the GCM model authentication tag
        uint8_t tag[16];
        if (EVP_CIPHER_CTX_ctrl(self.ctx, EVP_CTRL_GCM_GET_TAG, 16, tag) != 1)
        {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _finalizeWithErrorFail;
        }
        
        // set the tag attribute of the SCR
        self.scr.tag = [[NSData alloc] initWithBytes:tag length:16];
    }
    else
    {
        if (EVP_DecryptFinal_ex(self.ctx, NULL, &written) != 1) {
            CJOSE_ERROR(&err, CJOSE_ERR_CRYPTO);
            goto _finalizeWithErrorFail;
        }
    }
    return YES;
        
_finalizeWithErrorFail:
    
    if (nil != error) {
        *error = [CjoseWrapper errorWithCjoseErr:&err];
    }
    return NO;
}

@end
