//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleObjectResolver.h"

@import ObjectiveC;

#import "ALCVariableDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCObjectInstance.h"

@implementation ALCSimpleObjectResolver

-(int) order {
    // Put this injector last.
    return -1;
}

-(BOOL) injectObject:(id) finalObject dependency:(ALCVariableDependencyResolver *) dependency {
    
    if ([dependency.candidateInstances count] > 1) {

        NSMutableArray *objectDescriptions = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
        for (id<ALCModelObject> metadata in dependency.candidateInstances) {
            [objectDescriptions addObject:[metadata description]];
        }
        
        @throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
                                       reason:[NSString stringWithFormat:@"Expecting 1 object for %@, but found %lu:%@", dependency, [dependency.candidateInstances count], [objectDescriptions componentsJoinedByString:@", "]]
                                     userInfo:nil];
        return NO;
    }

    ALCObjectInstance *instance = [dependency.candidateInstances anyObject];
    
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
