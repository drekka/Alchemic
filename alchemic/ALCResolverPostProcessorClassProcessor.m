//
//  ALCResolverPostProcessorClassProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 2/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCResolverPostProcessorClassProcessor.h"
#import "ALCContext.h"
#import "ALCResolverPostProcessor.h"

@implementation ALCResolverPostProcessorClassProcessor {
    Protocol *_resolverProtocol;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _resolverProtocol = @protocol(ALCResolverPostProcessor);
    }
    return self;
}

-(void) processClass:(Class)class withContext:(ALCContext *)context {
    if (class_conformsToProtocol(class, _resolverProtocol)) {
        [context addResolverPostProcessor:[[class alloc] init]];
    }
}

@end
