//
//  ALCResourceLocatorClassProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 2/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCResourceLocatorClassProcessor.h"
#import "ALCResourceLocator.h"
#import "ALCContext.h"

@import ObjectiveC;

@implementation ALCResourceLocatorClassProcessor {
    Protocol *_resourceLocatorProtocol;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _resourceLocatorProtocol = @protocol(ALCResourceLocator);
    }
    return self;
}

-(void) processClass:(Class)class withContext:(ALCContext *)context {
    if (class_conformsToProtocol(class, _resourceLocatorProtocol)) {
        ALCInstance *instance = [[ALCInstance alloc] initWithClass:class];
        instance.finalObject = [[class alloc] init];
        instance.instantiate = YES;
        [context addInstance:instance];
    }
}


@end
