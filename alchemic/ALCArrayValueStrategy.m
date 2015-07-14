//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayValueStrategy.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCRuntime.h"
#import <Alchemic/ALCDependency.h>

@implementation ALCArrayValueStrategy

-(BOOL) canResolveValueForDependency:(ALCDependency *) dependency values:(NSSet<id> *) values {
    Class typeClass = dependency.valueClass;
    return (typeClass == NULL && [values count] > 1) || [typeClass isKindOfClass:[NSArray class]];
}

-(id) resolveValues:(NSSet<id> *) values {
    return values.allObjects;
}

@end
