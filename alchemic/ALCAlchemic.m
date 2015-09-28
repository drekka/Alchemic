//
//  alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAlchemic.h"
#import "ALCContext.h"
#import "ALCInternalMacros.h"
#import "ALCRuntime.h"
#import "ALCRuntimeScanner.h"

#import <StoryTeller/StoryTeller.h>

@implementation ALCAlchemic

static __strong ALCContext *__mainContext;

+(ALCContext *) mainContext {
    return __mainContext;
}

+(void) unload {
    __mainContext = nil;
}

+(void) load {
    dispatch_async(dispatch_queue_create("Alchemic", NULL), ^{
        @autoreleasepool {
            NSProcessInfo *processInfo = [NSProcessInfo processInfo];
            if (! [processInfo.arguments containsObject:@"--alchemic-nostart"]) {
                [self start];
            }
        }
    });
}

+(void) start {
    STLog(ALCHEMIC_LOG, @"Starting Alchemic ...");
    __mainContext = [[ALCContext alloc] init];
    NSSet<ALCRuntimeScanner *> *scanners = [NSSet setWithArray:@[
                                                                 [ALCRuntimeScanner modelScanner],
                                                                 [ALCRuntimeScanner configScanner],
                                                                 [ALCRuntimeScanner resourceLocatorScanner]
                                                                 ]];
    [ALCRuntime scanRuntimeWithContext:__mainContext runtimeScanners:scanners];
    [__mainContext start];
}

@end
