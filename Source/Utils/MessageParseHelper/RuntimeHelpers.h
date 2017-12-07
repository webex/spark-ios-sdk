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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN BOOL IsDebuggerAttached(void);
FOUNDATION_EXTERN void BreakIntoDebugger(void);
FOUNDATION_EXTERN NSString *NSStringFromBool(BOOL boolValue);
FOUNDATION_EXTERN NSString *_Nullable AtosCommandForCallStackReturnAddresses(NSArray<NSNumber *> *callStackReturnAddresses);

NS_ASSUME_NONNULL_END

#pragma mark Macros

#define SafeInvokeBlock(block, ...) block ? block(__VA_ARGS__) : nil

// This macro exists to trigger a change notification on a property of a managed object
// Use case: FRCs can only watch one entity at a time and not relationships, so to trigger an update with
// the FRC, a property on the watched object needs to be modified, and setting the value to itself triggers an update
// We found that triggering an update in the same moc change was the most consistent way to produce an update
#define TRIGGER_UPDATE(x) x = x
