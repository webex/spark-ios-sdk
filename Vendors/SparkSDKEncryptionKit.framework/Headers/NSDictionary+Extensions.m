#import "NSDictionary+Extensions.h"

@implementation NSDictionary (Extensions)

- (id)typesafeObjectForKey:(id)key class:(Class)classKind {
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self];
    if (nil != key && nil != classKind) {
        id obj = [dict objectForKey:key];
        if ((nil != obj) && [obj isKindOfClass:classKind]) {
            return obj;
        }
    }
    return nil;
}

@end
