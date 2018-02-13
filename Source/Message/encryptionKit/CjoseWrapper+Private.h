#import "CjoseWrapper.h"

#import "cjose/error.h"

@interface CjoseWrapper (Private)

/**
 Other classes in the Encryption group use cJose calls directly, so it's
 useful to make this a public method for their use.
 */
+ (NSError *)errorWithCjoseErr:(cjose_err *)err;

@end
