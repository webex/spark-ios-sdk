#import "SecureInputStream.h"

#import "CipherA256GCM.h"
#import "CjoseWrapper+Private.h"

@interface SecureInputStream ()

@property (nonatomic, readwrite) id<NSStreamDelegate> localDelegate;
@property (nonatomic, readwrite) NSStream *stream;
@property (nonatomic, readwrite) SecureContentReference *scr;
@property (nonatomic, readwrite) CipherA256GCM *cipher;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite) uint8_t *decbuf, *encbuf;
@property (nonatomic, readwrite) size_t declen, decptr, enclen, encptr;
@property (nonatomic, readwrite) size_t bytesEncrypted;
@property (nonatomic, readwrite) bool isOpen;

@end

@implementation SecureInputStream

- (instancetype)initWithStream:(NSInputStream *)stream
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
    
    // by default an NSInputStream should be its own delegate
    self.delegate = self;
    
    // initialize the cipher (hardcoded to the A256GCM for now)
    self.cipher = [[CipherA256GCM alloc] initWithSecureContentReference:scr error:error];
    if (nil == self.cipher) {
        return nil;
    }
    
    // set up the encrypted data buffer
    self.enclen = self.cipher.blockSize;
    self.encbuf = malloc(self.enclen);
    if (nil == self.encbuf) {
        if (nil != error) {
            CJOSE_ERROR(&err, CJOSE_ERR_NO_MEMORY);
            *error = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    self.encptr = self.enclen;

    // set up the decrypted data buffer
    self.declen = self.cipher.blockSize;
    self.decbuf = malloc(self.declen);
    if (nil == self.decbuf) {
        if (nil != error) {
            CJOSE_ERROR(&err, CJOSE_ERR_NO_MEMORY);
            *error = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }
    self.decptr = 0;
    
    self.bytesEncrypted = 0;
    self.isOpen = NO;
    return self;
}

-(void)dealloc {
    [self close];
    free(self.decbuf);
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode)
    {
        case NSStreamEventEndEncountered:
            // block this event to account for buffering
            break;

        case NSStreamEventOpenCompleted:
        case NSStreamEventHasBytesAvailable:
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventErrorOccurred:
        case NSStreamEventNone:
            // just pass these straight through if we have a real delegate
            if (self.delegate != self) {
                [self.delegate stream:self handleEvent:eventCode];
            }
    }
}

- (NSInteger)readFromBuffer:(uint8_t *)wbuf maxLength:(NSUInteger)requested {
    size_t copied = 0;
    NSInputStream *istream = (NSInputStream *)self.stream;

    // read from encbuf only
    if (self.encptr < self.enclen) {
        size_t space = self.enclen - self.encptr;
        size_t take = (requested < space) ? requested : space;
        memcpy(wbuf, self.encbuf + self.encptr, take);
        self.encptr += take;
        copied = take;
        
        // if encbuf is emptied and istream is at end, send event
        if ((self.delegate != self) && (0 == self.decptr) && (self.enclen == self.encptr) &&
            ((istream.streamStatus == NSStreamStatusClosed) ||
             (istream.streamStatus == NSStreamStatusAtEnd))) {
                [self.delegate stream:self handleEvent:NSStreamEventEndEncountered];
            }
    }

    return copied;
}

- (NSInteger)read:(uint8_t *)wbuf maxLength:(NSUInteger)requested {
    NSError *error;
    size_t copied = 0;
    NSInputStream *istream = (NSInputStream *)self.stream;
    self.error = nil;
    
    // if the input stream is in error or has not fully opened, return nothing
    if ((istream.streamStatus == NSStreamStatusError) ||
        (istream.streamStatus == NSStreamStatusNotOpen) ||
        (istream.streamStatus == NSStreamStatusOpening)) {
            return 0;
    }

    // if we have buffered ciphertext then read from there first
    copied = [self readFromBuffer:wbuf maxLength:requested];

    // if encbuf is not empty there's nothing left we can do
    if (self.encptr < self.enclen) {
        return copied;
    }

    // decrypt available bytes in increments of the cipher's native block size
    while (copied + self.declen <= requested) {
        
        // read from istream to try and fill the decbuf for encrypting
        if ((self.decptr < self.declen) && [istream hasBytesAvailable]) {
            self.decptr += [istream read:(self.decbuf + self.decptr)
                           maxLength:(self.declen - self.decptr)];
        }
        
        if (self.decptr == self.declen) {
            if ([self.cipher encryptBytes:self.decbuf
                             toBuffer:wbuf + copied
                           withLength:self.declen
                                error:&error] != (int)self.declen) {
                self.error = error;
                [self close];
                return -1;
            }
            self.decptr = 0;
            copied += self.declen;
        }
        else
        {
            // not enough bytes available to encrypt a full block, break
            break;
        }
    }

    // caller can't handle any (more) full blocks, decrypt to buffer
    if ((self.decptr < self.declen) && [istream hasBytesAvailable]) {
        self.decptr += [istream read:(self.decbuf + self.decptr)
                       maxLength:(self.declen - self.decptr)];
    }
    if ((self.decptr == self.declen) ||
        (istream.streamStatus == NSStreamStatusClosed) ||
        (istream.streamStatus == NSStreamStatusAtEnd))
    {
        if ([self.cipher encryptBytes:self.decbuf
                             toBuffer:self.encbuf
                           withLength:self.decptr
                                error:&error] != (int)self.decptr) {
            self.error = error;
            [self close];
            return -1;
        }
        self.enclen = self.decptr;
        self.decptr = 0;
        self.encptr = 0;
    }

    // make a final read from the buffered encrypted data
    copied += [self readFromBuffer:(wbuf + copied) maxLength:(requested - copied)];
    
    // return -1 if an error was set
    if (nil != self.error) {
        [self close];
        copied = -1;
    }
    
    if (0 < copied) {
        self.bytesEncrypted += copied;
    }
    return copied;
}

- (BOOL)hasBytesAvailable {
    return [(NSInputStream *)self.stream hasBytesAvailable];
}

- (void)close {
    if (self.isOpen) {
        self.isOpen = NO;
        NSError *error = nil;
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
