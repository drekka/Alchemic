//
//  ALCDefaultObjectResolverFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDefaultValueProcessorFactory.h"
#import "ALCSimpleValueProcessor.h"
#import "ALCArrayValueProcessor.h"

@implementation ALCDefaultValueProcessorFactory

-(id<ALCValueProcessor>) resolverForDependency:(id<ALCResolvable>) dependency {

    Class dependencyExpectsClass = dependency.objectClass;
    
    if ([ALCArrayValueProcessor canResolveClass:dependencyExpectsClass]) {
        return [[ALCArrayValueProcessor alloc] init];
    }

    return [[ALCSimpleValueProcessor alloc] init];

}

@end
