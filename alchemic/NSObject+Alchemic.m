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
#import "ALCObjectGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (Alchemic)

-(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments {

    // Get an invocation ready.
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = selector;

    // Load the arguments.
    [arguments enumerateObjectsUsingBlock:^(id<ALCDependency> dependency, NSUInteger idx, BOOL *stop) {
        STLog(self.class, @"Injecting argument at index %i", idx);
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
    id allocedObj = [self alloc];
    return [allocedObj invokeSelector:selector arguments:arguments];
}

-(void) resolveFactoryWithResolvingStack:(NSMutableArray<NSString *> *) resolvingStack
                           resolvingFlag:(BOOL *) resolvingFlag
                                   block:(void (^) (void)) block {

    id<ALCObjectGenerator> generator = (id<ALCObjectGenerator>) self;
    NSString *name = generator.defaultName;

    if (*resolvingFlag) {
        // If the object factory is in the same resolving chain, then we have a loop.
        if ([resolvingStack containsObject:name]) {
            [resolvingStack addObject:name];
            throwException(@"AlchemicCircularDependency", @"Circular dependency detected: %@", [resolvingStack componentsJoinedByString:@" -> "]);
        }
        return;
    }

    *resolvingFlag = YES;
    [resolvingStack addObject:name];
    block();
    [resolvingStack removeLastObject];
    *resolvingFlag = NO;
}

-(void) resolveDependencyWithResolvingStack:(NSMutableArray<NSString *> *) resolvingStack
                                   withName:(NSString *) name
                                      model:(id<ALCModel>) model {
    id<ALCDependency> dependency = (id<ALCDependency>) self;
    [resolvingStack addObject:name];
    [dependency resolveWithStack:resolvingStack model:model];
    [resolvingStack removeLastObject];
}

-(BOOL) dependenciesReady:(NSArray<id<ALCResolvable>> *) dependencies
            resolvingFlag:(BOOL *) resolvingFlag {


    // IF we have looped back here, consider us ready.
    if (*resolvingFlag) {
        return YES;
    }

    *resolvingFlag = YES;

    for (id<ALCResolvable> resolvable in dependencies) {
        if (!resolvable.ready) {
            *resolvingFlag = NO;
            return NO;
        }
    }

    *resolvingFlag = NO;
    return YES;
}

@end

NS_ASSUME_NONNULL_END
