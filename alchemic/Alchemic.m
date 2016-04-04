
#import "Alchemic.h"

#import <StoryTeller/StoryTeller.h>

#import "ALCContextImpl.h"

NSString *AlchemicDidCreateObject = @"AlchemicDidCreateObject";
NSString *AlchemicDidCreateObjectUserInfoObject = @"object";
NSString *AlchemicDidFinishStarting = @"AlchemicDidFinishStarting";

@implementation Alchemic

static __strong id<ALCContext> __mainContext;

+(id<ALCContext>) mainContext {
    return __mainContext;
}

+(void) load {
    dispatch_async(dispatch_queue_create("Alchemic", NULL), ^{
        @autoreleasepool {
            NSProcessInfo *processInfo = [NSProcessInfo processInfo];
            if (! [processInfo.arguments containsObject:@"--alchemic-nostart"]) {
                [self initContext];
                [__mainContext start];
            }
        }
    });
}

+(void) initContext {
    __mainContext = [[ALCContextImpl alloc] init];
    /*
     NSSet<ALCRuntimeScanner *> *scanners = [NSSet setWithArray:@[
     [ALCRuntimeScanner modelScanner],
     [ALCRuntimeScanner configScanner],
     [ALCRuntimeScanner resourceLocatorScanner]
     ]];
     [ALCRuntime scanRuntimeWithContext:__mainContext runtimeScanners:scanners];
     */
}

@end

