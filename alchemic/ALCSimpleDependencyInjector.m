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
#import "ALCObjectDescription.h"

@implementation ALCSimpleDependencyInjector

-(BOOL) injectObject:(id) finalObject dependency:(ALCDependency *) dependency {
    NSString *name = [[dependency.candidateObjectDescriptions allKeys] firstObject];
    ALCObjectDescription *objectDescription = dependency.candidateObjectDescriptions[name];
    id value = objectDescription.finalObject;
    logDependencyResolving(@"Injecting %s with a %s(%@)", ivar_getName(dependency.variable), class_getName([value class]), name);
    object_setIvar(finalObject, dependency.variable, value);
    return YES;
}

@end
