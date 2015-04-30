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

-(BOOL) injectObject:(id) finalObject dependency:(ALCDependency *) dependency {
    
    if ([dependency.candidateInstances count] > 1) {
        @throw [NSException exceptionWithName:@"AlchemicTooManyObjects"
                                       reason:[NSString stringWithFormat:@"Expected 1 object for dependency %s, found %lu", ivar_getName(dependency.variable), (unsigned long)[dependency.candidateInstances count]]
                                     userInfo:nil];
    }
    
    ALCInstance *instance = [dependency.candidateInstances anyObject];
    if (instance.finalObject == nil) {
        @throw [NSException exceptionWithName:@"AlchemicObjectNotCreated"
                                       reason:[NSString stringWithFormat:@"Dependency %s has not be set or instantiated", ivar_getName(dependency.variable)]
                                     userInfo:nil];
    }
    return [self injectObject:finalObject
                     variable:dependency.variable
                    withValue:instance.finalObject];
}

@end
