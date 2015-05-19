//
//  ALCModelObject.m
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractResolvable.h"
#import "ALCLogger.h"
#import "ALCContext.h"
#import "ALCDependency.h"
#import "ALCValueProcessorFactory.h"

@implementation ALCAbstractResolvable

@synthesize objectClass = _objectClass;
@synthesize object = _object;
@synthesize primary = _primary;

#pragma mark - Lifecycle

-(instancetype) initWithContext:(__weak ALCContext *) context objectClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _context = context;
        _objectClass = objectClass;
        _dependencies = [[NSMutableArray alloc] init];
        _valueProcessor = [context.valueProcessorFactory resolverForDependency:self];
    }
    return self;
}

-(void) addDependencyResolver:(ALCDependency *) dependency {
    [(NSMutableArray *) self.dependencies addObject:dependency];
}

-(void) resolveDependencies {
    for (ALCDependency *dependency in self.dependencies) {
        [dependency resolveUsingModel:_context.model];
        [dependency postProcess:self.context.resolverPostProcessors];
    }
}

-(void) instantiateObject {}

@end
