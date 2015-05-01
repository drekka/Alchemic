//
//  ALCInitStrategyClassProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 1/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCInitStrategyClassProcessor.h"
#import "ALCContext.h"
#import "ALCRuntime.h"
#import "ALCAbstractInitStrategy.h"

@implementation ALCInitStrategyClassProcessor {
    Class _abstractinitStrategyClass;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _abstractinitStrategyClass = [ALCAbstractInitStrategy class];
    }
    return self;
}

-(void) processClass:(Class)class withContext:(ALCContext *)context {
    if (class != _abstractinitStrategyClass
        && [ALCRuntime class:class extends:_abstractinitStrategyClass]) {
        [context addInitStrategy:class];
    }
}

@end
