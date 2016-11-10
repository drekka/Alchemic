
@import StoryTeller;
@import UIKit;

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCContextImpl.h>
#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation Alchemic

static __nullable __strong id<ALCContext> __mainContext;

+(id<ALCContext>) mainContext {
    return __mainContext;
}

+(void) initialize {
    // Decide whether to start.
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if ([processInfo.arguments containsObject:@"--alchemic-nostart"]) {
        return;
    }
    [self initContext];
}

+(void) initContext {
    __mainContext = [[ALCContextImpl alloc] init];
}

+(void) dropContext {
    __mainContext = nil;
}

+(void) load {
    if ([self mainContext]) {
        // Because we are executing before the UIApplication has been started, it's possible for Alchemic to not find the delegate. So we post the startup block to the main thread to get it executing after the app startup code has executed.
        dispatch_async(dispatch_get_main_queue(), ^{
            // Now execute the startup on Alchemic's background thread.
            [[self mainContext] executeInBackground:^{
                [ALCRuntime scanRuntimeWithContext:__mainContext];
                [__mainContext start];
            }];
        });
    }
}

@end

NS_ASSUME_NONNULL_END


