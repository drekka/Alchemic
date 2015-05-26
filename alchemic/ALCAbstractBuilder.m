//
//  ALCModelObject.m
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"
#import "ALCLogger.h"
#import "ALCContext.h"
#import "ALCDependency.h"

@implementation ALCAbstractBuilder

// Properties from protocol
@synthesize valueType = _valueType;
@synthesize primary = _primary;

#pragma mark - Lifecycle

-(instancetype) initWithContext:(__weak ALCContext *) context valueType:(ALCType *) valueType {
    self = [super init];
    if (self) {
        _context = context;
        _valueType = valueType;
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addDependency:(ALCDependency *) dependency {
    [(NSMutableArray *) self.dependencies addObject:dependency];
}

-(void) resolve {
    for (ALCDependency *dependency in self.dependencies) {
        [dependency resolve];
    }
}

@end
