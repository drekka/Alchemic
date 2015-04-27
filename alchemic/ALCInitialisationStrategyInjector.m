//
//  AlchemicRuntimeInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 17/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCInitialisationStrategyInjector.h"

@import UIKit;

@import ObjectiveC;
#import "ALCLogger.h"
#import "ALCInstance.h"
#import "ALCInitialisationStrategy.h"

@implementation ALCInitialisationStrategyInjector {
    NSArray *_strategyClasses;
}

static BOOL injected = NO;

-(void) dealloc {
    if (!injected) {
        return;
    }
    [self resetRuntime];
}

-(instancetype) initWithStrategyClasses:(NSArray *) strategyClasses {
    self = [super init];
    if (self) {
        _strategyClasses = strategyClasses;
    }
    return self;
}

-(void) replaceInitsInModelClasses:(NSDictionary *) model {

    if (injected) {
        logRuntime(@"Wrappers already injected into classes");
        return;
    }

    // Extract a list of root classes from the model.
    NSArray *rootInstances = [self findRootInstances:[model allValues]];

    // Now hook into the classes.
    for (ALCInstance *instance in rootInstances) {
        for (Class initStrategy in _strategyClasses) {
            if ([initStrategy canWrapInit:instance]) {
                [instance addInitialisationStrategy:[[initStrategy alloc] initWithInstance:instance]];
            }
        }
    }
}

-(NSArray *) findRootInstances:(NSArray *) instances {
    
    // Copy all the classes into an array for checking.
    NSMutableSet *modelClasses = [[NSMutableSet alloc] initWithCapacity:[instances count]];
    for (ALCInstance *instance in instances) {
        [modelClasses addObject:instance.forClass];
    }

    // Work out which classes we need to inject hooks into
    NSMutableArray *rootInstances = [[NSMutableArray alloc] init];
    for (ALCInstance *instance in instances) {
        
        // Check each ancestor class in turn. If any are in the list, then ignore the current class.
        Class parentClass = class_getSuperclass(instance.forClass);
        while (parentClass != NULL) {
            if ([modelClasses containsObject:parentClass]) {
                // The parent is in the model too so stop looking.
                break;
            }
            parentClass = class_getSuperclass(parentClass);
        }
        
        // If we are here and the parent is NULL then we are safe to add the class to the final list.
        if (parentClass == NULL) {
            logRuntime(@"Scheduling '%@' %s for init wrapper injection", instance.name, class_getName(instance.forClass));
            [rootInstances addObject:instance];
        }
        
    }

    return rootInstances;

}

-(void) resetRuntime {
}

@end
