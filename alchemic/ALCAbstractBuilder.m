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
#import "ALCVariableDependency.h"

@implementation ALCAbstractBuilder

// Properties from protocol
@synthesize valueType = _valueType;
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize lazy = _lazy;

#pragma mark - Lifecycle

-(instancetype) initWithContext:(__weak ALCContext *) context valueType:(ALCType *) valueType {
    self = [super init];
    if (self) {
        _context = context;
        _valueType = valueType;
        _dependencies = [[NSMutableArray alloc] init];
        _lazy = YES;
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

-(BOOL) isInstantiated {
    return _value != nil;
}

-(id) instantiate {
    
    // Value will only have a value if this is not a factory.
    if (_value != nil) {
        return _value;
    }
    
    // Get the value and store it if we are not a factory.
    id newValue = [self resolveValue];
    if (!_factory) {
        _value = newValue;
    }
    return newValue;
}

-(id) value {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id) resolveValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
