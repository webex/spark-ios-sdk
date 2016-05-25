
#import <Foundation/Foundation.h>
#import "CustomLogger.h"
#import "WmeLogger.h"

@interface WmeLogManager : NSObject

@property WmeLogger *logger;

+(WmeLogManager *)sharedInstance;

-(void)addLogger:(id<CustomLogger>)logger;

@end





