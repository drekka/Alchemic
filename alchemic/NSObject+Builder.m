//
//  NSObject+Alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 15/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "NSObject+Builder.h"
#import "AlchemicAware.h"
#import "ALCInternalMacros.h"

@implementation NSObject (Alchemic)

-(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments {

    // Get an invocation ready.
    STLog(ALCHEMIC_LOG, @"Creating an invocation using selector %@", NSStringFromSelector(selector));
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = selector;

    // Load the arguments.
    [arguments enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
        id finalValue = [value isKindOfClass:[NSNull class]] ? nil : value;
        [inv setArgument:&finalValue atIndex:(NSInteger) idx + 2];
    }];

    [inv invokeWithTarget:self];

    id __unsafe_unretained returnObj;
    [inv getReturnValue:&returnObj];
    STLog(ALCHEMIC_LOG, @"Returning a %s", class_getName([returnObj class]));
    return returnObj;
}

-(void) injectWithDependencies:(NSSet<ALCVariableDependency *> *) dependencies {

    STLog([self class], @"Injecting %lu dependencies into a %@ instance", [dependencies count], NSStringFromClass([self class]));
    for (ALCVariableDependency *dependency in dependencies) {
        [(ALCVariableDependency *)dependency injectInto:self];
    }

    if ([self respondsToSelector:@selector(alchemicDidInjectDependencies)]) {
        STLog([self class], @"Notifying that inject did finish");
        [(id<AlchemicAware>)self alchemicDidInjectDependencies];
    }
}

-(void) injectVariable:(Ivar) variable withValue:(id) value {
    STLog([self class], @"Injecting %@.%s", NSStringFromClass([self class]), ivar_getName(variable));
    object_setIvar(self, variable, value);
}

@end
