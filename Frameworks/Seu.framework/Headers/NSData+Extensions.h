#import <Foundation/Foundation.h>

@interface NSData (Extensions)

- (NSData *)gzipDecompressData;
- (NSData *)gzipCompressData;
+ (NSData *)tarWithDataForFileName:(NSDictionary *)files;
- (NSString *)hexEncodedString;
- (BOOL)isTIFF;

@end
