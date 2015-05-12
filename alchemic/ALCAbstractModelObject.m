//
//  ALCModelObject.m
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractModelObject.h"
#import "ALCLogger.h"
#import "ALCContext.h"
#import "ALCResolver.h"

@implementation ALCAbstractModelObject

@synthesize objectClass = _objectClass;
@synthesize object = _object;
@synthesize name = _name;
@synthesize primary = _primary;

#pragma mark - Lifecycle

-(instancetype) initWithContext:(__weak ALCContext *) context objectClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _context = context;
        _objectClass = objectClass;
        _name = NSStringFromClass(objectClass);
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addDependencyResolver:(ALCResolver *) dependency {
    [(NSMutableArray *) self.dependencies addObject:dependency];
}

-(void) resolveDependencies {
    logDependencyResolving(@"Resolving dependencies for %@", [self description]);
    for (ALCResolver *dependency in self.dependencies) {
        [dependency resolveUsingModel:_context.model];
        [dependency postProcess:self.context.resolverPostProcessors];
    }
}

-(void) instantiateObject {}

@end
