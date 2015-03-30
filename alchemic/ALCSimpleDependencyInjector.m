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
    NSString *name = [[dependency.candidateObjectDescriptions allKeys] firstObject];
    ALCInstance *objectDescription = dependency.candidateObjectDescriptions[name];
    id value = objectDescription.finalObject;
    logDependencyResolving(@"Injecting %s with '%3$@' (%2$s)", ivar_getName(dependency.variable), class_getName([value class]), name);
    object_setIvar(finalObject, dependency.variable, value);
    return YES;
}

@end
