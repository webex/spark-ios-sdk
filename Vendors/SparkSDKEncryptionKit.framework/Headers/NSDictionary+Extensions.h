#import <Foundation/Foundation.h>

@interface NSDictionary (Extensions)

/**
 This method help to perform a very common task in extracting attributes
 in a typesafe manner.
 */
- (id)typesafeObjectForKey:(id)key class:(Class)classKind;


@end
