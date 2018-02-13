#import "SecureOutputStream.h"

#import "CipherA256GCM.h"
#import "CjoseWrapper+Private.h"

@interface SecureOutputStream ()

@property (nonatomic, readwrite) id<NSStreamDelegate> localDelegate;
@property (nonatomic, readwrite) NSStream *stream;
@property (nonatomic, readwrite) SecureContentReference *scr;
@property (nonatomic, readwrite) CipherA256GCM *cipher;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite) uint8_t *decbuf, *encbuf;
@property (nonatomic, readwrite) size_t declen, decptr, enclen, encptr;
@property (nonatomic, readwrite) bool isOpen;

@end

@implementation SecureOutputStream

- (instancetype)initWithStream:(NSOutputStream *)stream
                           scr:(SecureContentReference *)scr
                         error:(NSError **)error {
    cjose_err err;
    
    // check for valid params
    if ((nil == stream) || (nil == scr)) {
        if (nil != error) {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_ARG);
            *error = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    
    // initialize the base class
    self = [super init];
    if (nil == self) {
        if (nil != error) {
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            *error = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    
    // initialize class members
    self.stream = stream;
    self.scr = scr;
    [self.stream setDelegate:self];
    
    // initialize the cipher (hardcoded to the A256GCM for now)
    self.cipher = [[CipherA256GCM alloc] initWithSecureContentReference:scr error:error];
    if (nil == self.cipher) {
        return nil;
    }
    
    // by default an NSOutputStream should be its own delegate
    self.delegate = self;
    
    // set up the encrypted data buffer
    self.declen = self.cipher.blockSize;
    self.decbuf = malloc(self.declen);
    if (nil == self.decbuf) {
        if (nil != error) {
            CJOSE_ERROR(&err, CJOSE_ERR_NO_MEMORY);
            *error = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    self.decptr = self.declen;
    
    // set up the decrypted data buffer
    self.enclen = self.cipher.blockSize;
    self.encbuf = malloc(self.enclen);
    if (nil == self.encbuf) {
        if (nil != error) {
            CJOSE_ERROR(&err, CJOSE_ERR_NO_MEMORY);
            *error = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    self.encptr = 0;
    
    self.isOpen = NO;
    return self;
}

-(void)dealloc {
    [self close];
    free(self.decbuf);
    free(self.encbuf);
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode)
    {
        case NSStreamEventEndEncountered:
            // block this event to account for buffering
            break;

        case NSStreamEventHasSpaceAvailable:
            // flush buffers when space becomes available
            [self flush];
            
        case NSStreamEventOpenCompleted:
        case NSStreamEventHasBytesAvailable:
        case NSStreamEventErrorOccurred:
        case NSStreamEventNone:
            // just pass these straight through if we have a real delegate
            if (self.delegate != self) {
                [self.delegate stream:self handleEvent:eventCode];
            }
    }
}

- (NSInteger)write:(const uint8_t *)rbuf maxLength:(NSUInteger)requested {
    NSError *error;
    NSUInteger copied = 0;
    self.error = nil;
    
    // do nothing of the stream is in a bad state
    if ((self.stream.streamStatus == NSStreamStatusError) ||
        (self.stream.streamStatus == NSStreamStatusNotOpen) ||
        (self.stream.streamStatus == NSStreamStatusOpening)) {
        return 0;
    }
    
    // if we have cached ciphertext then steal from rbuf to fill encbuf
    if (0 < self.encptr) {
        size_t space = self.enclen - self.encptr;
        size_t take = (requested < space) ? requested : space;
        memcpy(self.encbuf + self.encptr, rbuf, take);
        self.encptr += take;
        copied += take;
        
        // if not enough bytes to fill in the encbuf, just return
        if (self.encptr < self.enclen) {
            return copied;
        }
    }
    
    // flush current decbuf and encbuf, if fully flushed then refill from rbuf
    while ([self flush] && (copied + self.declen <= requested))
    {
        if ([self.cipher decryptBytes:rbuf + copied
                         toBuffer:self.decbuf
                       withLength:self.declen
                            error:&error] != (int)self.declen) {
            self.error = error;
            [self close];
            return -1;
        }
        self.decptr = 0;
        copied += self.declen;
    }
    
    // if encbuf is empty, and less than a block of data left in rbuf, cache it
    if ((self.encptr == 0) && (requested - copied < self.enclen)) {
        self.encptr = requested - copied;
        memcpy(self.encbuf, rbuf + copied, self.encptr);
        copied += self.encptr;
    }
    
    // return -1 if an error was set
    if (NULL != self.error) {
        copied = -1;
    }
    
    return copied;
}

- (BOOL)flushDecrypted {
    NSOutputStream *ostream = (NSOutputStream *)self.stream;
    if ((self.decptr < self.declen) && [ostream hasSpaceAvailable]) {
        self.decptr += [ostream write:(self.decbuf + self.decptr)
                        maxLength:(self.declen - self.decptr)];
    }
    return self.decptr == self.declen;
}

- (BOOL)flush {
    NSError *error;
    
    // if decbuf gets fully flushed, try to also encrypt and flush encbuf
    if ([self flushDecrypted] && (self.encptr == self.enclen)) {
        if ([self.cipher decryptBytes:self.encbuf
                         toBuffer:self.decbuf
                       withLength:self.enclen
                            error:&error] != (int)self.enclen) {
            self.error = error;
            return NO;
        }
        self.encptr = 0;
        self.decptr = 0;
        [self flushDecrypted];
    }
    
    return (self.decptr == self.declen) && (self.encptr == 0);
}

- (BOOL)hasSpaceAvailable {
    return [(NSOutputStream *)self.stream hasSpaceAvailable];
}

- (void)close {
    if (self.isOpen) {
        NSError *error = nil;
        BOOL flushed = [self flush];
        while (!flushed) {
            if ((self.decptr == self.declen) && (self.encptr > 0)) {
                self.enclen = self.encptr;
                self.declen = self.encptr;
                self.decptr = self.encptr;
            }
            flushed = [self flush];
        }
        [self.cipher finalizeWithError:&error];
        self.error = error;
        [self.stream close];
    }
}

- (void)open {
    [self.stream open];
    self.isOpen = YES;
}

- (id<NSStreamDelegate>)delegate {
    return self.localDelegate;
}

- (void)setDelegate:(id<NSStreamDelegate>)delegate {
    if (delegate == nil) {
        self.localDelegate = self;
    }
    self.localDelegate = delegate;
}

- (id)propertyForKey:(NSString *)key {
    return [self.stream propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    return [self.stream setProperty:property forKey:key];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
    return [self.stream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
    return [self.stream removeFromRunLoop:aRunLoop forMode:mode];
}

- (NSStreamStatus)streamStatus {
    if (nil != self.error) {
        return NSStreamStatusError;
    }
    return [self.stream streamStatus];
}

- (NSError *)streamError {
    if (nil != self.error) {
        return self.error;
    }
    return [self.stream streamError];
}

@end
