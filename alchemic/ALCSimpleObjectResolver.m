//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleObjectResolver.h"

@import ObjectiveC;

#import "ALCDependencyResolver.h"
#import "ALCVariableDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCObjectInstance.h"
#import "ALCRuntime.h"

@implementation ALCSimpleObjectResolver

-(BOOL) canResolveClass:(Class)class {
    return ! [ALCRuntime class:class isKindOfClass:[NSArray class]];
}

-(id) resolveDependency:(ALCDependencyResolver *) dependency {

    ALCObjectInstance *instance = [dependency.candidateInstances anyObject];
    id object = instance.object;
    
    if (object == nil) {
        @throw [NSException exceptionWithName:@"AlchemicNilObject"
                                       reason:[NSString stringWithFormat:@"Dependency %s has not created an object", ivar_getName(((ALCVariableDependencyResolver *)dependency).variable)]
                                     userInfo:nil];
    }

    return object;
}

-(void) validateDependencyCandidates:(ALCDependencyResolver *)dependency {

    if ([dependency.candidateInstances count] > 1) {
        
        NSMutableArray *candidates = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
        for (id<ALCModelObject> modelObject in dependency.candidateInstances) {
            [candidates addObject:[modelObject description]];
        }
        
        @throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
                                       reason:[NSString stringWithFormat:@"Expecting 1 object for %@, but found %lu:%@", dependency, [dependency.candidateInstances count], [candidates componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }

}

@end
