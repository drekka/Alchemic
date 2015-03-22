//
//  ALCAbstractDependencyResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 17/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractDependencyResolver.h"

@implementation ALCAbstractDependencyResolver

-(id) resolveDependency:(ALCDependencyInfo *)dependency {
    return nil;
}

-(instancetype) initWithModel:(NSDictionary *) model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

@end
