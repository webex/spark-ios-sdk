
#import <Foundation/Foundation.h>
#import "CustomLogger.h"

@class WmeLogger;

@interface WmeLogManager : NSObject

@property WmeLogger *logger;

+(WmeLogManager *)sharedInstance;

-(void)addLogger:(id<CustomLogger>)logger;

@end





