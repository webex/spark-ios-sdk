#import <Foundation/Foundation.h>

@interface KmsResponse : NSObject

@property (nonatomic, readonly) NSUInteger sequence;
@property (nonatomic, readonly) NSUInteger status;
@property (nonatomic, readonly) NSString *reason;

- (instancetype)initWithSequence:(NSUInteger)status
                        sequence:(NSUInteger)sequence
                          reason:(NSString *)reason
                           error:(NSError **)error;

- (NSString *)serializeWithAdditionalAttributes:(NSDictionary *)attributes;

@end
