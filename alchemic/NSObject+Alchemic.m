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
        return [ALCInstantiation instantiationWithObject:returnObj completion:NULL];
    }
    return nil;
}

-(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {
    return [[self class] object:self invokeSelector:selector arguments:arguments];
}

+(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {
    return [self object:self invokeSelector:selector arguments:arguments];
}

-(void) resolveFactoryWithResolvingStack:(NSMutableArray<NSString *> *) resolvingStack
                            resolvedFlag:(BOOL *) resolvedFlag
                                   block:(void (^) (void)) block {

    id<ALCInstantiator> generator = (id<ALCInstantiator>) self;
    NSString *name = generator.defaultName;

    if (*resolvedFlag) {
        // If the object factory is in the same resolving chain, then we have a loop.
        if ([resolvingStack containsObject:name]) {
            [resolvingStack addObject:name];
            throwException(@"AlchemicCircularDependency", @"Circular dependency detected: %@", [resolvingStack componentsJoinedByString:@" -> "]);
        }

        // We are enumerating dependencies then we have looped back through a property injection so return.
        STLog(generator.objectClass, @"Factory %@ already resolved", NSStringFromClass(generator.objectClass));
        return;
    }

    STLog(generator.objectClass, @"Resolving factory %@", name);
    *resolvedFlag = YES;
    [resolvingStack addObject:name];
    block();
    [resolvingStack removeLastObject];
}

-(BOOL) dependenciesReady:(NSArray<id<ALCResolvable>> *) dependencies checkingStatusFlag:(BOOL *) checkingFlag {

    // IF we have looped back here, consider us ready.
    if (*checkingFlag) {
        return YES;
    }

    *checkingFlag = YES;

    for (id<ALCResolvable> resolvable in dependencies) {
        // If a dependency is not ready then we stop checking and return a failure.
        if (!resolvable.ready) {
            *checkingFlag = NO;
            return NO;
        }
    }

    *checkingFlag = NO;
    return YES;
}

@end

NS_ASSUME_NONNULL_END
