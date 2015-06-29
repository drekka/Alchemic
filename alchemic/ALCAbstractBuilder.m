//
//  ALCModelObject.m
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCContext.h"
#import "ALCDependency.h"
#import "ALCVariableDependency.h"

@implementation ALCAbstractBuilder

// Properties from protocol
@synthesize valueType = _valueType;
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize createOnStartup = _createOnStartup;
@synthesize value = _value;

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

-(id) instantiate {
    
    // Get the value and store it if we are not a factory.
    id newValue = [self resolveValue];
    if (!_factory) {
        _value = newValue;
    }
    return newValue;
}

-(BOOL) shouldCreateOnStartup {
    return _createOnStartup && _value == nil;
}

-(id) resolveValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
