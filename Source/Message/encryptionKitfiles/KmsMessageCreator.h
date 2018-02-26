#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KmsMessageCreator <NSObject>

- (NSString *)kmsMessageForCreateResource:(NSString *)keyUrl userIds:(NSArray *)userIds error:(NSError **)error;
- (NSString *)kmsMessageForAddAuthorization:(NSString *)userId resourceUri:(NSString *)resourceUri error:(NSError **)error;
- (NSString *)kmsMessageForDeleteAuthorization:(NSString *)userId resourceUri:(NSString *)resourceUri error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
