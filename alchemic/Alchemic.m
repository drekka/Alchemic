
@import StoryTeller;
@import UIKit;

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCContextImpl.h>
#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

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
                STStartLogging(@"LogAll");
            }
            
            if ([processInfo.arguments containsObject:@"--alchemic-colorizeLog"]) {
                ((STConsoleLogger *)[STStoryTeller storyTeller].logger).addXcodeColours = YES;
                ((STConsoleLogger *)[STStoryTeller storyTeller].logger).messageColour = [UIColor blackColor];
                ((STConsoleLogger *)[STStoryTeller storyTeller].logger).detailsColour = [UIColor lightGrayColor];
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


