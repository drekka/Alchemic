//
//  MethodArgumentDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 11/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArgumentDependencyResolver.h"
#import "ALCModelObjectFactoryMethod.h"

@implementation ALCArgumentDependencyResolver {
    __weak ALCModelObjectFactoryMethod *_factoryMethod;
    int _argumentIndex;
}

-(instancetype) initWithFactoryMethod:(__weak ALCModelObjectFactoryMethod *) factoryMethod
                        argumentIndex:(int) argumentIndex
                             matchers:(NSSet *) dependencyMatchers {
    self = [super initWithMatchers:dependencyMatchers];
    if (self) {
        _factoryMethod = factoryMethod;
        _argumentIndex = argumentIndex;
        self.dependencyMatchers = dependencyMatchers;
    }
    return self;
}

@end
