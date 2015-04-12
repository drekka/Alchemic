//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleDependencyInjector.h"

#import "ALCDependency.h"
#import <objc/runtime.h>
#import "ALCLogger.h"
#import "ALCInstance.h"

@implementation ALCSimpleDependencyInjector

-(BOOL) injectObject:(id) finalObject dependency:(ALCDependency *) dependency {
    ALCInstance *objectDescription = [dependency.candidateObjectDescriptions lastObject];
    id value = objectDescription.finalObject;
    logRuntime(@"Injecting %s with a %2$s", ivar_getName(dependency.variable), class_getName([value class]));
    object_setIvar(finalObject, dependency.variable, value);
    return YES;
}

@end
