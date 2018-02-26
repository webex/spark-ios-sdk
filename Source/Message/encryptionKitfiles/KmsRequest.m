#import "KmsRequest.h"

#import "CjoseWrapper+Private.h"

@interface KmsRequest ()

@property (nonatomic, readwrite) NSString *requestId;
@property (nonatomic, readwrite) NSString *method;
@property (nonatomic, readwrite) NSString *uri;

@end

@implementation KmsRequest

- (instancetype)initWithRequestId:(NSString *)requestId
                         clientId:(NSString *)clientId
                           userId:(NSString *)userId
                           bearer:(NSString *)bearer
                           method:(NSString *)method
                              uri:(NSString *)uri
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
        self.requestId = requestId;
        self.clientId = clientId;
        self.userId = userId;
        self.bearer = bearer;
        self.method = method;
        self.uri = uri;
    }
    
    return self;
}

- (NSString *)serialize {
    NSMutableDictionary *value = [@{ @"client" : @{
                                             @"clientId" : self.clientId ?: @"",
                                             @"credential" : @{
                                                     @"userId" : self.userId ?: @"",
                                                     @"bearer" : self.bearer ?: @""
                                                     }
                                             },
                                     @"method" : self.method ?: @"",
                                     @"uri" : self.uri ?: @"",
                                     @"requestId" : self.requestId ?: @""
                                     } mutableCopy];
    [self.additionalAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        value[key] = obj;
    }];
    NSLog(@"====== request serialize: %@",value);
    NSData *valueData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
    return [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
}

@end
