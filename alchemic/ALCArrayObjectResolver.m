//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayObjectResolver.h"
#import "ALCVariableDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCModelObject.h"
#import "ALCRuntime.h"

@implementation ALCArrayObjectResolver

-(BOOL) canResolveClass:(Class)class {
    return ! [ALCRuntime class:class isKindOfClass:[NSArray class]];
}

-(id) resolveDependency:(ALCDependencyResolver *)dependency {

    if ([dependency.candidateInstances count] == 1) {
        id value = ((id<ALCModelObject>)[dependency.candidateInstances anyObject]).object;
        return  [value isKindOfClass:[NSArray class]] ? value : @[value];
    }
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
    [dependency.candidateInstances enumerateObjectsUsingBlock:^(id<ALCModelObject> modelObject, BOOL *stop) {
        id value = modelObject.object;
        if (value != nil) {
            [values addObject:value];
        }
    }];
    return values;
    
}

-(void) validateDependencyCandidates:(ALCDependencyResolver *)dependency {
    // Nothing to do here.
}

@end
