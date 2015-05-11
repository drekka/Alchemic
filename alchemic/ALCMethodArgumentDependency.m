//
//  MethodArgumentDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 11/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCMethodArgumentDependency.h"
#import "ALCFactoryMethod.h"

@implementation ALCMethodArgumentDependency {
    __weak ALCFactoryMethod *_factoryMethod;
    int _argumentIndex;
}

-(instancetype) initWithFactoryMethod:(__weak ALCFactoryMethod *) factoryMethod argumentIndex:(int) argumentIndex matchers:(NSSet *) dependencyMatchers {
    self = [super initWithMatchers:dependencyMatchers];
    if (self) {
        _factoryMethod = factoryMethod;
        _argumentIndex = argumentIndex;
        self.dependencyMatchers = dependencyMatchers;
    }
    return self;
}

@end
