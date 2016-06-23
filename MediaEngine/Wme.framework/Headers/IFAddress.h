
#import <Foundation/Foundation.h>

@interface IFAddress : NSObject

- (id)initWithName:(NSString*)name andAddr:(NSString*)addr;

@property (nonatomic, readonly) NSString *ifaName;
@property (nonatomic, readonly) NSString *ifaAddr;

@end
