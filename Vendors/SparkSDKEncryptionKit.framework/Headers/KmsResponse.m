#import "KmsResponse.h"

#import "CjoseWrapper+Private.h"

@interface KmsResponse ()

@property (nonatomic, readwrite) NSUInteger sequence;
@property (nonatomic, readwrite) NSUInteger status;
@property (nonatomic, readwrite) NSString *reason;

@end

@implementation KmsResponse

- (instancetype)initWithSequence:(NSUInteger)status
                        sequence:(NSUInteger)sequence
                          reason:(NSString *)reason
                           error:(NSError **)error {

    self = [super init];
    if (nil == self) {
        if (error) {
            cjose_err err;
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            (*error) = [CjoseWrapper errorWithCjoseErr:&err];
        }
    }
    else {
        self.status = status;
        self.sequence = sequence;
        self.reason = reason;
    }
    
    return self;
}

- (NSString *)serializeWithAdditionalAttributes:(NSDictionary *)attributes {
    NSMutableDictionary *value = [@{ @"status" : @(self.status),
                                     @"sequence" : @(self.sequence),
                                     @"reason" : self.reason ?: @""
                                     } mutableCopy];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        value[key] = obj;
    }];
    NSData *valueData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
    return [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
}

@end
