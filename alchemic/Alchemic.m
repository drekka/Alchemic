
#import "Alchemic.h"

#import <StoryTeller/StoryTeller.h>

#import "ALCContextImpl.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

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
            if ([processInfo.arguments containsObject:@"--alchemic-logAll"]) {
                STStartLogging(@"");
            }
            if (! [processInfo.arguments containsObject:@"--alchemic-nostart"]) {
                [self initContext];
                [ALCRuntime scanRuntimeWithContext:__mainContext];
                [__mainContext start];
            }
        }
    });
}

+(void) initContext {
    __mainContext = [[ALCContextImpl alloc] init];
}

@end

NS_ASSUME_NONNULL_END


