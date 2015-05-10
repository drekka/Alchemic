//
//  ALCModelObject.m
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCModelObject.h"

@implementation ALCModelObject

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
    }
    return self;
}


-(void) resolveDependencies {}

-(void) instantiateObject {}

-(void) injectDependenciesInto:(id) object {}

@end
