//
//  NSObject+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "NSObject+Alchemic.h"
#import "ALCResolvable.h"
#import "ALCRuntime.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (Alchemic)

-(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {

    // Get an invocation ready.
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = selector;

    // Load the arguments.
    [arguments enumerateObjectsUsingBlock:^(id<ALCDependency> dependency, NSUInteger idx, BOOL *stop) {
        [dependency setInvocation:inv argumentIndex:(int) idx + 2];
    }];

    [inv invokeWithTarget:self];

    const char *returnType = sig.methodReturnType;
    if (strcmp(returnType, "v") != 0) {
        id __unsafe_unretained returnObj;
        [inv getReturnValue:&returnObj];
        return returnObj;
    }
    return nil;
}

+(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {
    return [self invokeSelector:selector arguments:arguments];
}

-(void) enumerateDependencies:(NSArray<id<ALCResolvable>> *) dependencies
              enumeratingFlag:(BOOL *) enumeratingFlag
                    withBlock:(DependencyTraverseBlock) block {

    if (!*enumeratingFlag) {
        return;
    }

    *enumeratingFlag = YES;
    [dependencies enumerateObjectsUsingBlock:^(id<ALCResolvable> resolvable, NSUInteger idx, BOOL *stop) {
        block(resolvable, stop);
    }];
    *enumeratingFlag = NO;
}

@end

NS_ASSUME_NONNULL_END
