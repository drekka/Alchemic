//
//  ALCSimpleLogger.m
//  alchemic
//
//  Created by Derek Clarkson on 21/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCLogger.h"
#import "ALCInternal.h"
#import <pthread/pthread.h>

static int __alchemicLogOptions = 0;

@implementation ALCLogger

+(void) setLoggingSwitch:(AlchemicLogCategory) categorySwitch {
    __alchemicLogOptions |= categorySwitch;
}

+(void) logCategory:(AlchemicLogCategory) category
             source:(const char *) source
               line:(int) line
            message:(NSString *) messageTemplate, ... {

    if ( ! (__alchemicLogOptions & category)) {
        return;
    }
    
    va_list args;
    va_start(args, messageTemplate);
    NSString *msg = [[NSString alloc] initWithFormat:messageTemplate arguments:args];
    va_end(args);
    
    const char *categoryName = [ALCLogger categoryNameForEnum:category];
    
    //NSString *processName = [[NSProcessInfo processInfo] processName];
    //NSString *threadName = [NSThread currentThread].name;
    //NSString *finalThreadName = threadName == nil || [threadName length] == 0 ? [NSString stringWithFormat:@"%x", pthread_mach_thread_np(pthread_self())] : threadName;
    NSString *finalThreadName = [NSString stringWithFormat:@"%x", pthread_mach_thread_np(pthread_self())];
    
    //printf("%5$s %6$s [%1$s] %2$s(%3$i) %4$s\n", categoryName, source, line, [msg UTF8String], [finalThreadName UTF8String], [processName UTF8String]);
    printf("%5$4s %1$12s: %2$s(%3$i) %4$s\n", categoryName, source, line, [msg UTF8String], [finalThreadName UTF8String]);
    
}

+(const char *) categoryNameForEnum:(AlchemicLogCategory) category {
    if (category == AlchemicLogCategoryCreation) return "Creation";
    if (category == AlchemicLogCategoryObjectResolving) return "Resolving";
    if (category == AlchemicLogCategoryConfiguration) return "Config";
    if (category == AlchemicLogCategoryProxies) return "Proxies";
    if (category == AlchemicLogCategoryRuntime) return "Runtime";
    return "Registration";
}

@end
