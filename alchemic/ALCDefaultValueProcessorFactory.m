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
#import "ALCLogger.h"

@implementation ALCDefaultValueProcessorFactory

-(id<ALCValueProcessor>) resolverForDependency:(ALCDependency *) dependency {

    if ([ALCArrayValueProcessor canResolveValueForDependency:dependency]) {
        return [[ALCArrayValueProcessor alloc] init];
    }

    return [[ALCSimpleValueProcessor alloc] init];

}

@end
