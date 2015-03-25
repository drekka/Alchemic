//
//  ALCSimpleObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleObjectFactory.h"
#import "ALCLogger.h"
#import "ALCObjectDescription.h"
#import "ALCContext.h"

#import <objc/runtime.h>

@implementation ALCSimpleObjectFactory {
    __weak ALCContext *_context;
}

-(instancetype) initWithContext:(ALCContext *) context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}

-(id) createObjectFromObjectDescription:(ALCObjectDescription *) objectDescription {
    logCreation(@"Creating object using %s::init", class_getName(objectDescription.forClass));
    return [[objectDescription.forClass alloc] init];
}

@end
