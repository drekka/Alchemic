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
#import "ALCClassBuilder.h"
#import "ALCInitStrategy.h"
#import "ALCClassMatcher.h"
#import "ALCType.h"

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
    for (ALCClassBuilder *classBuilder in [self findRootClassBuildersInModel:model]) {
        for (Class initStrategy in _strategyClasses) {
            if ([initStrategy canWrapInit:classBuilder]) {
                [classBuilder addInitStrategy:[[initStrategy alloc] initWithClassBuilder:classBuilder]];
            }
        }
    }
}

-(NSArray *) findRootClassBuildersInModel:(NSDictionary *) model {
    
    // First find all instances.
    NSSet *builders = [model buildersWithMatchers:[NSSet setWithObject:[ALCClassMatcher matcherWithClass:[ALCClassBuilder class]]]];
    
    // Copy all the classes into an array
    NSMutableSet *builderClasses = [[NSMutableSet alloc] initWithCapacity:[builders count]];
    for (ALCClassBuilder *builder in builders) {
        [builderClasses addObject:builder.valueType.typeClass];
    }

    // Work out which classes we need to inject hooks into
    NSMutableArray *rootBuilders = [[NSMutableArray alloc] init];
    for (ALCClassBuilder *builder in builders) {
        
        // Check each ancestor class in turn. If any are in the list, then ignore the current class.
        Class parentClass = class_getSuperclass(builder.valueType.typeClass);
        while (parentClass != NULL) {
            if ([builderClasses containsObject:parentClass]) {
                // The parent is in the model too so stop looking.
                break;
            }
            parentClass = class_getSuperclass(parentClass);
        }
        
        // If we are here and the parent is NULL then we are safe to add the class to the final list.
        if (parentClass == NULL) {
            logRuntime(@"Scheduling %s for init wrapper injection", class_getName(builder.valueType.typeClass));
            [rootBuilders addObject:builder];
        }
        
    }

    return rootBuilders;

}

-(void) resetRuntime {
}

@end
