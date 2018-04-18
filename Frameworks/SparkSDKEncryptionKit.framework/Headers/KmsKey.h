#import <Foundation/Foundation.h>

@interface KmsKey : NSObject

@property (nonatomic, readonly) NSString *uri;
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *clientId;
@property (nonatomic, readonly) NSString *createDate;
@property (nonatomic, readonly) NSString *expirationDate;
@property (nonatomic, readonly) NSString *jwk;

- (instancetype)initWithUri:(NSString *)uri
                     userId:(NSString *)userId
                   clientId:(NSString *)clientId
                 createDate:(NSString *)createDate
             expirationDate:(NSString *)expirationDate
                        jwk:(NSString *)jwk
                      error:(NSError **)error;

- (instancetype)initFromDictionary:(NSDictionary *)root error:(NSError **)error;

- (NSDictionary *)dictionaryRepresentation;

- (NSString *)serialize;

@end
