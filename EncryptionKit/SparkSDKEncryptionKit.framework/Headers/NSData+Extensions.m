#import "NSData+Extensions.h"

#include <zlib.h>

static size_t kTarBlockLength = 512;
static size_t kTarNameOffset = 0;
static size_t kTarNameLength = 100;
static size_t kTarModeOffset = 100;
static size_t kTarModeLength = 6;
static size_t kTarSizeOffset = 124;
static size_t kTarSizeLength = 8;
static size_t kTarChecksumOffset = 148;
static size_t kTarChecksumLength = 8;

@implementation NSData (Extensions)

- (NSData *)gzipDecompressData {
    if ([self length] == 0) return self;

    if ([self length] > UINT_MAX) {
        return nil;
    }

    unsigned full_length = (unsigned int)[self length];
    unsigned half_length = (unsigned int)[self length] / 2;

    NSMutableData *decompressed = [NSMutableData dataWithLength:full_length + half_length];
    BOOL done = NO;
    int status;

    z_stream strm;
    strm.next_in = (Bytef *) [self bytes];
    strm.avail_in = (unsigned int)[self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;

    if (inflateInit2(&strm, (15 + 32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy:half_length];
        strm.next_out = (unsigned char *) [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([decompressed length] - strm.total_out);

        // Inflate another chunk.
        status = inflate(&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd(&strm) != Z_OK) return nil;

    // Set real length.
    if (done) {
        [decompressed setLength:strm.total_out];
        return [NSData dataWithData:decompressed];
    }
    else return nil;
}

- (NSData *)gzipCompressData {
    if ([self length] == 0) return self;

    if ([self length] > UINT_MAX) {
        return nil;
    }

    z_stream strm;

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in = (Bytef *) [self bytes];
    strm.avail_in = (unsigned int)[self length];

    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION

    if (deflateInit2(&strm, Z_BEST_COMPRESSION, Z_DEFLATED, (15 + 16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;

    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion

    do {

        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy:16384];

        strm.next_out = (unsigned char *) [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([compressed length] - strm.total_out);

        deflate(&strm, Z_FINISH);

    } while (strm.avail_out == 0);

    deflateEnd(&strm);

    [compressed setLength:strm.total_out];
    return [NSData dataWithData:compressed];
}

// NOTE: This method was written by @hadougla from the spec and not based on another implemenation.
+ (NSMutableData *)tarWithDataForFileName:(NSDictionary *)dataForFileName {
    NSUInteger blockCount = 2;
    for (NSData *data in [dataForFileName allValues]) {
        blockCount += 1 + ceil((double)[data length] / kTarBlockLength);
    }
    NSMutableData *result = [[NSMutableData alloc] initWithCapacity:(blockCount * kTarBlockLength)];
    
    uint8_t headerBytes[kTarBlockLength];
    memset(headerBytes, 0, kTarBlockLength);
    
    for (NSString *name in dataForFileName) {
        NSData *data = dataForFileName[name];
        
        [name getBytes:(headerBytes + kTarNameOffset) maxLength:kTarNameLength usedLength:nil encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, name.length) remainingRange:nil];
        
        NSString *mode = @"664";
        [mode getBytes:(headerBytes + kTarModeOffset) maxLength:kTarModeLength usedLength:nil encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, mode.length) remainingRange:nil];
        
        NSString *size = [NSString stringWithFormat:@"%0*llo", (int)kTarSizeLength, (unsigned long long)[data length]];
        [size getBytes:(headerBytes + kTarSizeOffset) maxLength:kTarSizeLength usedLength:nil encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, size.length) remainingRange:nil];
        
        NSString *checksumPlaceholder = @"        ";
        [checksumPlaceholder getBytes:(headerBytes + kTarChecksumOffset) maxLength:kTarChecksumLength usedLength:nil encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, checksumPlaceholder.length) remainingRange:nil];
        
        uint32_t byteSum = 0;
        for (NSUInteger i = 0; i < kTarBlockLength; i++) {
            byteSum += (uint8_t)headerBytes[i];
        }
        
        NSString *checksum = [NSString stringWithFormat:@"%0*o", (int)kTarChecksumLength, byteSum];
        [checksum getBytes:(headerBytes + kTarChecksumOffset) maxLength:kTarChecksumLength usedLength:nil encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, checksum.length) remainingRange:nil];
        
        [result appendBytes:headerBytes length:kTarBlockLength];
        [result appendData:data];
        
        memset(headerBytes, 0, kTarBlockLength);
        NSUInteger paddingLength = (kTarBlockLength - [result length]) % kTarBlockLength;
        [result appendBytes:headerBytes length:paddingLength];
    }
    
    [result appendBytes:headerBytes length:kTarBlockLength];
    [result appendBytes:headerBytes length:kTarBlockLength];
    
    return result;
}

- (NSString *)hexEncodedString {
    NSMutableString *result = [NSMutableString stringWithCapacity:self.length * 2];
    uint8_t *bytes = (uint8_t *)self.bytes;
    for (NSUInteger i = 0; i < self.length; i++) {
        [result appendFormat:@"%02x", bytes[i]];
    }
    return result;
}

- (BOOL)isTIFF {
    if (self.length >= 4) {
        uint8_t bytes[4];
        [self getBytes:bytes length:4];
        return (bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0x2A && bytes[3] == 0x00) ||
               (bytes[0] == 0x4D && bytes[1] == 0x4D && bytes[2] == 0x00 && bytes[3] == 0x2A);
    }
    return NO;
}

@end
