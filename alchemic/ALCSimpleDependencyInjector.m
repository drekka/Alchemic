//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleDependencyInjector.h"

#import "ALCDependency.h"
@import ObjectiveC;
#import "ALCLogger.h"
#import "ALCInstance.h"

@implementation ALCSimpleDependencyInjector

-(BOOL) injectObject:(id) object dependency:(ALCDependency *) dependency {
    ALCInstance *instance = [dependency.candidateInstances lastObject];
    id value = instance.finalObject;
    Ivar var = dependency.variable;
    logRuntime(@"Injecting %s::%s with a %2$s",object_getClassName(object) , ivar_getName(var), object_getClassName(value));
    object_setIvar(object, var, value);
    return YES;
}

@end
