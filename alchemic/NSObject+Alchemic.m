//
//  NSObject+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/NSObject+Alchemic.h>

#import <Alchemic/ALCDependency.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCInstantiator.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCMethodArgumentDependency.h>
#import <Alchemic/ALCResolvable.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/ALCType.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (Alchemic)

-(id) invokeSelector:(SEL) selector arguments:(nullable NSArray<id<ALCDependency>> *) arguments {
    return [[self class] object:self invokeSelector:selector arguments:arguments];
}

+(id) invokeSelector:(SEL) selector arguments:(nullable NSArray<id<ALCDependency>> *) arguments {
    return [self object:self invokeSelector:selector arguments:arguments];
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
            resolvedFlag:(BOOL *) resolvedFlag
                   block:(ALCSimpleBlock) block {

    id<ALCResolvable> resolvableSelf = (id<ALCResolvable>) self;

    // First check if we have already been resolved.
    if (*resolvedFlag) {

        // If the object factory is in the same resolving chain, then we have a loop.
        NSUInteger stackIndex = [resolvingStack indexOfObject:resolvableSelf];
        if (stackIndex != NSNotFound) {

            // Check through the circular reference in the stack and only if we find a method argument can we not resolve this. Method arguments are agressively resolved.
            // Use this style of loop to stop issues with NSUInteger and negative values.
            NSUInteger i = resolvingStack.count;
            do {
                i--;
                if ([resolvingStack[i] isKindOfClass:[ALCMethodArgumentDependency class]]) {

                    // A method is found. Bad.
                    [resolvingStack addObject:resolvableSelf];

                    // Build names based on resolvable default model keys.
                    NSMutableArray<NSString *> *names = [[NSMutableArray alloc] initWithCapacity:resolvingStack.count];
                    [resolvingStack enumerateObjectsUsingBlock:^(id<ALCResolvable> stackResolvable, NSUInteger idx, BOOL *stop) {
                        [names addObject:stackResolvable.resolvingDescription];
                    }];

                    throwException(AlchemicResolvingException, @"Circular dependency detected: %@", [names componentsJoinedByString:@" -> "]);
                }
            } while (i > stackIndex);
        }

        // We are enumerating dependencies then we have looped back through a property injection so return.
        STLog(resolvableSelf.type, @"%@ already resolved", NSStringFromClass(resolvableSelf.type.objcClass));
        return;
    }

    *resolvedFlag = YES;
    [resolvingStack addObject:resolvableSelf];
    block();
    [resolvingStack removeLastObject];
}

#pragma mark - Internal

+(id) object:(id) object invokeSelector:(SEL) selector arguments:(nullable NSArray<id<ALCDependency>> *) arguments {

    STLog(self, @"Executing %@", [ALCRuntime forClass:[self class] selectorDescription:selector]);

    // Get an invocation ready.
    NSMethodSignature *sig = [object methodSignatureForSelector:selector];

    // Error checks
    if (!sig) {
        throwException(AlchemicMethodNotFoundException, @"Method %@ not found", [ALCRuntime forClass:[self class] selectorDescription:selector]);
    }

    if (strcmp(sig.methodReturnType, "@") != 0) {
        throwException(AlchemicIllegalArgumentException, @"Method %@ does not return an object", [ALCRuntime forClass:[self class] selectorDescription:selector]);
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv retainArguments];
    inv.selector = selector;

    // Load the arguments.
    [arguments enumerateObjectsUsingBlock:^(id<ALCDependency> dependency, NSUInteger idx, BOOL *stop) {
        STLog(self.class, @"Injecting argument at index %lu", (unsigned long)idx);
        [dependency injectObject:inv];
    }];

    [inv invokeWithTarget:object];

    id __unsafe_unretained returnObj;
    [inv getReturnValue:&returnObj];
    return returnObj;
}

@end

NS_ASSUME_NONNULL_END
