#import <Foundation/Foundation.h>

@interface KmsRequest : NSObject

@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *bearer;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSString *uri;
@property (nonatomic, copy) NSDictionary *additionalAttributes;

- (instancetype)initWithRequestId:(NSString *)requestId
                         clientId:(NSString *)clientId
                           userId:(NSString *)userId
                           bearer:(NSString *)bearer
                           method:(NSString *)method
                              uri:(NSString *)uri
                            error:(NSError **)error;

- (NSString *)serialize;

@end
