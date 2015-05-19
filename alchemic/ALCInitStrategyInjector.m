//
//  AlchemicRuntimeInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 17/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCInitStrategyInjector.h"

@import UIKit;

@import ObjectiveC;
#import "ALCLogger.h"
#import "ALCResolvableObject.h"
#import "ALCInitStrategy.h"
#import "ALCClassMatcher.h"

@implementation ALCInitStrategyInjector {
    NSSet *_strategyClasses;
}

static BOOL injected = NO;

-(void) dealloc {
    if (!injected) {
        return;
    }
    [self resetRuntime];
}

-(instancetype) initWithStrategyClasses:(NSSet *) strategyClasses {
    self = [super init];
    if (self) {
        _strategyClasses = strategyClasses;
    }
    return self;
}

-(void) replaceInitsInModelClasses:(NSDictionary *) model {
    return;
    if (injected) {
        logRuntime(@"Wrappers already injected into classes");
        return;
    }

    // Now hook into the classes.
    for (ALCResolvableObject *instance in [self findRootInstancesInModel:model]) {
        for (Class initStrategy in _strategyClasses) {
            if ([initStrategy canWrapInit:instance]) {
                [instance addInitStrategy:[[initStrategy alloc] initWithInstance:instance]];
            }
        }
    }
}

-(NSArray *) findRootInstancesInModel:(NSDictionary *) model {
    
    // First find all instances of ALCInstance.
    NSSet *instances = [model resolvablesWithMatchers:[NSSet setWithObject:[[ALCClassMatcher alloc] initWithClass:[ALCResolvableObject class]]]];
    
    // Copy all the classes into an array for Against the list..
    NSMutableSet *modelClasses = [[NSMutableSet alloc] initWithCapacity:[instances count]];
    for (ALCResolvableObject *instance in instances) {
        [modelClasses addObject:instance.objectClass];
    }

    // Work out which classes we need to inject hooks into
    NSMutableArray *rootInstances = [[NSMutableArray alloc] init];
    for (ALCResolvableObject *instance in instances) {
        
        // Check each ancestor class in turn. If any are in the list, then ignore the current class.
        Class parentClass = class_getSuperclass(instance.objectClass);
        while (parentClass != NULL) {
            if ([modelClasses containsObject:parentClass]) {
                // The parent is in the model too so stop looking.
                break;
            }
            parentClass = class_getSuperclass(parentClass);
        }
        
        // If we are here and the parent is NULL then we are safe to add the class to the final list.
        if (parentClass == NULL) {
            logRuntime(@"Scheduling %s for init wrapper injection", class_getName(instance.objectClass));
            [rootInstances addObject:instance];
        }
        
    }

    return rootInstances;

}

-(void) resetRuntime {
}

@end
