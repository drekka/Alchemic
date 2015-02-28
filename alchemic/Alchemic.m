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
    
    @autoreleasepool {
        
        // Initiate the main context.
        __mainContext = [[ALCContext alloc] init];
        
        // Perform a scan of the runtime for injectable classes.
        dispatch_async(dispatch_queue_create("Class scan", NULL), ^{
            [ALCRuntime scanForMacros];
            [__mainContext start];
        });
    }
}

+(void) registerSingleton:(Class) singletonClass {
    [__mainContext registerSingleton:singletonClass];
}

+(void) registerClass:(Class) class withInjectionPoints:(NSString *) injs, ... {
    va_list args;
    va_start(args, injs);
    for (NSString *arg = injs; arg != nil; arg = va_arg(args, NSString *)) {
        [__mainContext registerInjection: arg inClass:class];
    }
    va_end(args);
}

@end
