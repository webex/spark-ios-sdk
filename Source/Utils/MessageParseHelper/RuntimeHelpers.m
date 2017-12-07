#import "RuntimeHelpers.h"

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <sys/sysctl.h>

BOOL IsDebuggerAttached(void) {
    // https://developer.apple.com/library/mac/qa/qa1361/_index.html
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid() };
    struct kinfo_proc info;
    info.kp_proc.p_flag = 0;
    BOOL isDebuggerAttached = NO;
    if (sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &(size_t){ sizeof(info) }, NULL, 0) == 0) {
        isDebuggerAttached = ((info.kp_proc.p_flag & P_TRACED) != 0);
    }
    
    return isDebuggerAttached;
}

void BreakIntoDebugger(void) {
    // We use __builtin_trap so the debugger breaks into the correct thread context.
    // To continue debugging the process, simply drag the green line execution marker down a line, answer 'Move' at the prompt, then hit continue.
    __builtin_trap();
}

NSString *NSStringFromBool(BOOL boolValue) {
    return boolValue ? @"YES" : @"NO";
}

NSString *_Nullable AtosCommandForCallStackReturnAddresses(NSArray<NSNumber *> *callStackReturnAddresses) {
    const char *executablePath = [[[NSBundle mainBundle] executablePath] UTF8String];
    for (uint32_t index = 0; index < _dyld_image_count(); index++) {
        const char *imageName = _dyld_get_image_name(index);
        if (imageName && strcmp(executablePath, imageName) == 0) {
            intptr_t imageSlide = _dyld_get_image_vmaddr_slide(index);
#ifndef __LP64__
            const struct segment_command *command = getsegbyname("__TEXT");
#else
            const struct segment_command_64 *command = getsegbyname("__TEXT");
#endif
            NSMutableString *atosCommand = [[NSMutableString alloc] initWithFormat:@"atos -o Spark.app.dSYM/Contents/Resources/DWARF/Spark %@ 0x%lx", command ? @"-l" : @"-s", (unsigned long)(command ? (command->vmaddr + imageSlide) : imageSlide)];
            for (NSNumber *callStackReturnAddress in callStackReturnAddresses) {
                [atosCommand appendFormat:@" 0x%lx", callStackReturnAddress.unsignedLongValue];
            }
            
            return atosCommand;
        }
    }
    
    return nil;
}
