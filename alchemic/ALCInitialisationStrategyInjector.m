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

-(instancetype) init {
    self = [super init];
    if (self) {
        _initialisationStrategies = @[];
    }
    return self;
}

-(void) addInitWrapperStrategy:(id<ALCInitialisationStrategy>) wrapperInitialisationStrategy {
    logConfig(@"Adding strategy: %s", class_getName([wrapperInitialisationStrategy class]));
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:wrapperInitialisationStrategy];
}

-(void) executeStrategies:(NSArray *)classes withContext:(ALCContext *)context {
    
    if (injected) {
        logObjectResolving(@"Wrappers already injected into classes");
        return;
    }

    // Reduce the list to just root classes.
    NSArray *rootClasses = [self findRootClassesInArray:classes];

    // Now hook into the classes.
    for (Class class in rootClasses) {
        for (id<ALCInitialisationStrategy, ALCInitialisationStrategyManagement> initStrategy in [_initialisationStrategies reverseObjectEnumerator]) {
            if ([initStrategy canWrapInitInClass:class]) {
                logObjectResolving(@"%s wrapping init in %s", class_getName([initStrategy class]), class_getName(class));
                [initStrategy wrapInitInClass:class withContext:context];
            }
        }
    }
}

-(NSArray *) findRootClassesInArray:(NSArray *) classes {
    
    // Work out which classes we need to inject hooks into.
    NSMutableArray *rootClasses = [[NSMutableArray alloc] init];
    [classes enumerateObjectsUsingBlock:^(Class currentClass, NSUInteger idx, BOOL *stop) {
        
        // Check the ancestory of the class.
        // If any of the parents appear in the list of injectable classes then skip to the next class.
        // After this loop the only classes added to the list should be top level ones.
        Class parent = class_getSuperclass(currentClass);
        while (parent != NULL) {
            
            // If the parent is in the list of injectable classes then end checking.
            if ([rootClasses containsObject:parent]) {
                logObjectResolving(@"Parent class (%s) of %s scheduled for initialiser injection", class_getName(parent), class_getName(currentClass));
                return;
            }
            parent = class_getSuperclass(parent);
        }
        
        // The class must be a root class with no parents in the list.
        [rootClasses addObject:currentClass];
        
    }];
    return rootClasses;

}

-(void) resetRuntime {
    [_initialisationStrategies enumerateObjectsUsingBlock:^(id<ALCInitialisationStrategy, ALCInitialisationStrategyManagement> strategy, NSUInteger idx, BOOL *stop) {
        [strategy resetClasses];
    }];
}

@end
