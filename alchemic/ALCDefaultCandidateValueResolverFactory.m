//
//  ALCDefaultObjectResolverFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDefaultCandidateValueResolverFactory.h"
#import "ALCSimpleCandidateValueResolver.h"
#import "ALCArrayCandidateValueResolver.h"

@implementation ALCDefaultCandidateValueResolverFactory

-(id<ALCCandidateValueResolver>) resolverForDependency:(id<ALCModelObject>) dependency {

    Class dependencyExpectsClass = dependency.objectClass;
    
    if ([ALCArrayCandidateValueResolver canResolveClass:dependencyExpectsClass]) {
        return [[ALCArrayCandidateValueResolver alloc] init];
    }

    return [[ALCSimpleCandidateValueResolver alloc] init];

}

@end
