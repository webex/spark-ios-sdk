#import "KmsKey.h"

#import "CjoseWrapper+Private.h"
#import "NSDictionary+Extensions.h"

@interface KmsKey ()

@property (nonatomic, readwrite) NSString *uri;
@property (nonatomic, readwrite) NSString *userId;
@property (nonatomic, readwrite) NSString *clientId;
@property (nonatomic, readwrite) NSString *createDate;
@property (nonatomic, readwrite) NSString *expirationDate;
@property (nonatomic, readwrite) NSString *jwk;

@end

@implementation KmsKey

- (instancetype)initWithUri:(NSString *)uri
                     userId:(NSString *)userId
                   clientId:(NSString *)clientId
                 createDate:(NSString *)createDate
             expirationDate:(NSString *)expirationDate
                        jwk:(NSString *)jwk
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
        self.uri = uri;
        self.userId = userId;
        self.clientId = clientId;
        self.createDate = createDate;
        self.expirationDate = expirationDate;
        self.jwk = jwk;
    }
    
    return self;
}

- (instancetype)initFromDictionary:(NSDictionary *)root error:(NSError **)error {
    self = [super init];
    if (nil == self) {
        if (error) {
            cjose_err err;
            CJOSE_ERROR(&err, CJOSE_ERR_INVALID_STATE);
            *error = [CjoseWrapper errorWithCjoseErr:&err];
        }
        return nil;
    }

    self.uri = [root typesafeObjectForKey:@"uri" class:[NSString class]];
    self.userId = [root typesafeObjectForKey:@"userId" class:[NSString class]];
    self.clientId = [root typesafeObjectForKey:@"clientId" class:[NSString class]];
    self.createDate = [root typesafeObjectForKey:@"createDate" class:[NSString class]];
    self.expirationDate = [root typesafeObjectForKey:@"expirationDate" class:[NSString class]];
    
    NSDictionary *dictJwk = [root typesafeObjectForKey:@"jwk" class:[NSDictionary class]];
    if (nil != dictJwk) {
        NSData *dataJwk = [NSJSONSerialization dataWithJSONObject:dictJwk options:0 error:error];
        if (nil != dataJwk) {
            self.jwk = [[NSString alloc] initWithData:dataJwk encoding:NSUTF8StringEncoding];
        }
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{ @"uri" : self.uri,
              @"jwk" : [NSJSONSerialization JSONObjectWithData:[self.jwk dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] ?: @{},
              @"userId" : self.userId,
              @"clientId" : self.clientId,
              @"createDate" : self.createDate,
              @"expirationDate" : [self.expirationDate description],
              };
}

- (NSString *)serialize {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.dictionaryRepresentation options:0 error:nil] encoding:NSUTF8StringEncoding];
}

@end
