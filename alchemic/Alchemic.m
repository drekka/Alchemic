//
//  alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "Alchemic.h"
#import "ALCRuntime.h"
#import "ALCContext.h"

@implementation Alchemic

static __strong ALCContext *__mainContext;

+(ALCContext *) mainContext {
    return __mainContext;
}

+(void) load {
    dispatch_async(dispatch_queue_create("Alchemic", NULL), ^{
        @autoreleasepool {
            __mainContext = [[ALCContext alloc] init];
            [ALCRuntime scanRuntimeWithContext:__mainContext];
            [__mainContext start];
        }
    });
}

@end
