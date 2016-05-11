#import <Foundation/Foundation.h>

/** The following macros allow for simple validated construction of key paths. See SPKRuntimeHelpersTests.m for examples. */
#define SELSTR(x) NSStringFromSelector(@selector(x))
#define KEYPATH(...) [ @[ __VA_ARGS__ ] componentsJoinedByString:@"."]

#define WEAKEN(var) typeof(var) __weak weak_##var = (var)
#define STRENGTHEN(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
typeof(var) __strong var = weak_##var \
_Pragma("clang diagnostic pop") \

#define IF_STRENGTHEN(var) STRENGTHEN(var); if (var)
#define IF_NOT_STRENGTHEN(var) STRENGTHEN(var); if (!var)
#define IF_NOT_STRENGTHEN_RETURN(var) STRENGTHEN(var); if (!var) { return; }

/** The following macro allows for simple macro that allows singletons to be created with one block. See SPKRuntimeHelpersTests.m for examples. */
#define DISPATCH_ONCE_SINGLETON(block) \
    static id singletonObject; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        singletonObject = block(); \
    }); \
    return singletonObject;

FOUNDATION_EXTERN BOOL isDebuggerAttached(void);
FOUNDATION_EXTERN BOOL breakIntoDebugger(void);
FOUNDATION_EXTERN NSString *NSStringFromBool(BOOL boolValue);
FOUNDATION_EXTERN NSString *atosCommandForCallStackReturnAddresses(NSArray *callStackReturnAddresses);

#pragma mark Macros

#define SafeInvokeBlock(block, ...) block ? block(__VA_ARGS__) : nil
