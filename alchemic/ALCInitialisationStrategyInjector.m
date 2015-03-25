//
//  AlchemicRuntimeInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 17/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCInitialisationStrategyInjector.h"

@import UIKit;

#import <objc/runtime.h>
#import "ALCLogger.h"
#import "ALCObjectDescription.h"
#import "ALCInitialisationStrategyManagement.h"
#import "ALCInitialisationStrategy.h"

@implementation ALCInitialisationStrategyInjector {
    NSArray *_initialisationStrategies;
}

static BOOL injected = NO;

-(void) dealloc {
    if (!injected) {
        return;
    }
    [self resetRuntime];
}

-(instancetype) initWithStrategies:(NSArray *) strategies {
    self = [super init];
    if (self) {
        _initialisationStrategies = strategies;
    }
    return self;
}

-(void) executeStrategiesOnObjects:(NSDictionary *) managedObjects withContext:(ALCContext *) context {

    if (injected) {
        logRuntime(@"Wrappers already injected into classes");
        return;
    }

    // Reduce the list to just root classes.
    NSArray *rootClasses = [self findRootClasses:[managedObjects allValues]];

    // Now hook into the classes.
    for (Class class in rootClasses) {
        for (id<ALCInitialisationStrategy, ALCInitialisationStrategyManagement> initStrategy in [_initialisationStrategies reverseObjectEnumerator]) {
            if ([initStrategy canWrapInitInClass:class]) {
                [initStrategy wrapInitInClass:class withContext:context];
            }
        }
    }
}

-(NSArray *) findRootClasses:(NSArray *) objectDescriptionList {
    
    // Work out which classes we need to inject hooks into.
    NSMutableArray *rootClasses = [[NSMutableArray alloc] init];
    [objectDescriptionList enumerateObjectsUsingBlock:^(ALCObjectDescription *objectDescription, NSUInteger idx, BOOL *stop) {
        
        // Check the ancestory of the class.
        // If any of the parents appear in the list of injectable classes then skip to the next class.
        // After this loop the only classes added to the list should be top level ones.
        Class baseClass = class_getSuperclass(objectDescription.forClass);
        while (baseClass != NULL) {
            
            // If the parent is in the list of injectable classes then end checking.
            if ([rootClasses containsObject:baseClass]) {
                logRuntime(@"Parent class (%s) of %s scheduled for initialiser injection", class_getName(baseClass), class_getName(objectDescription.forClass));
                return;
            }
            baseClass = class_getSuperclass(baseClass);
        }
        
        // The class must be a root class with no parents in the list.
        logRuntime(@"Adding root class: %s", class_getName(baseClass));
        [rootClasses addObject:baseClass];
        
    }];
    return rootClasses;

}

-(void) resetRuntime {
    [_initialisationStrategies enumerateObjectsUsingBlock:^(id<ALCInitialisationStrategy, ALCInitialisationStrategyManagement> strategy, NSUInteger idx, BOOL *stop) {
        [strategy resetClasses];
    }];
}

@end
