//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleDependencyInjector.h"

@import ObjectiveC;

#import "ALCVariableDependency.h"
#import "ALCLogger.h"
#import "ALCInstance.h"

@implementation ALCSimpleDependencyInjector

-(int) order {
    // Put this injector last.
    return -1;
}

-(BOOL) injectObject:(id) finalObject dependency:(ALCVariableDependency *) dependency {
    
    if ([dependency.candidateInstances count] > 1) {

        NSMutableArray *objectDescriptions = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
        for (id<ALCObjectMetadata> metadata in dependency.candidateInstances) {
            [objectDescriptions addObject:[metadata description]];
        }
        
        @throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
                                       reason:[NSString stringWithFormat:@"Expecting 1 object for %@, but found %lu:%@", dependency, [dependency.candidateInstances count], [objectDescriptions componentsJoinedByString:@", "]]
                                     userInfo:nil];
        return NO;
    }

    ALCInstance *instance = [dependency.candidateInstances anyObject];
    
    if (instance.object == nil) {
        @throw [NSException exceptionWithName:@"AlchemicObjectNotCreated"
                                       reason:[NSString stringWithFormat:@"Dependency %s has not be set or instantiated", ivar_getName(dependency.variable)]
                                     userInfo:nil];
    }
    
    [self injectObject:finalObject
              variable:dependency.variable
             withValue:instance.object];
    return YES;
}

@end
