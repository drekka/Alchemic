//
//  ALCAbstractDependencyResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 17/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCDependencyInfo.h"

@implementation ALCAbstractDependencyResolver {
@protected
    __weak ALCContext *_context;
}

-(NSArray *) resolveDependency:(ALCDependencyInfo *)dependency inObject:(id)object withObjectStore:(ALCObjectStore *)objectStore {
    return nil;
}

-(instancetype) initWithContext:(__weak ALCContext *) context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}

@end
