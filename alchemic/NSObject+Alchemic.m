//
//  NSObject+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "NSObject+Alchemic.h"
#import "ALCResolvable.h"
#import "ALCRuntime.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "ALCInstantiator.h"
#import "ALCInstantiation.h"
#import "NSArray+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (Alchemic)

+(id) object:(id) object invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {

    STLog(self, @"Executing %@", [ALCRuntime selectorDescription:[self class] selector:selector]);

    // Get an invocation ready.
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv retainArguments];
    inv.selector = selector;

    // Load the arguments.
    [arguments enumerateObjectsUsingBlock:^(id<ALCDependency> dependency, NSUInteger idx, BOOL *stop) {
        STLog(self.class, @"Injecting argument at index %i", idx);
        [dependency setInvocation:inv argumentIndex:(int) idx + 2];
    }];

    [inv invokeWithTarget:object];

    const char *returnType = sig.methodReturnType;
    if (strcmp(returnType, "v") != 0) {
        id __unsafe_unretained returnObj;
        [inv getReturnValue:&returnObj];
        return returnObj;
    }
    return nil;
}

-(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {
    return [[self class] object:self invokeSelector:selector arguments:arguments];
}

+(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {
    return [self object:self invokeSelector:selector arguments:arguments];
}

-(void) resolveFactoryWithResolvingStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                            resolvedFlag:(BOOL *) resolvedFlag
                                   block:(ALCSimpleBlock) block {

    id<ALCResolvable> resolvable = (id<ALCResolvable>) self;

    // First check if we have already been resolved.
    if (*resolvedFlag) {

        // If the object factory is in the same resolving chain, then we have a loop.
        if ([resolvingStack containsObject:resolvable]) {
            
            [resolvingStack addObject:resolvable];
            throwException(@"AlchemicCircularDependency",
                           @{@"stack":resolvingStack},
                           @"Circular dependency detected: %@", [resolvingStack componentsJoinedByString:@" -> "]);
        }

        // We are enumerating dependencies then we have looped back through a property injection so return.
        STLog(resolvable.objectClass, @"%@ already resolved", NSStringFromClass(resolvable.objectClass));
        return;
    }

    *resolvedFlag = YES;
    [resolvingStack addObject:resolvable];
    block();
    [resolvingStack removeLastObject];
}

-(BOOL) dependenciesReady:(NSArray<id<ALCResolvable>> *) dependencies checkingStatusFlag:(BOOL *) checkingFlag {

    // If this flag is set then we have looped back to the original variable. So consider everything to be good.
    if (*checkingFlag) {
        return YES;
    }

    // Set the checking flag so that we can detect loops.
    *checkingFlag = YES;

    for (id<ALCResolvable> resolvable in dependencies) {
        // If a dependency is not ready then we stop checking and return a failure.
        if (!resolvable.ready) {
            *checkingFlag = NO;
            return NO;
        }
    }

    // All dependencies are good to go.
    *checkingFlag = NO;
    return YES;
}

@end

NS_ASSUME_NONNULL_END
