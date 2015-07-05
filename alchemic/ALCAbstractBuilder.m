//
//  ALCModelObject.m
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/ALCContext.h>
#import <Alchemic/ALCDependency.h>
#import "ALCVariableDependency.h"

@implementation ALCAbstractBuilder

// Properties from protocol
@synthesize valueClass = _valueClass;
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize createOnStartup = _createOnStartup;
@synthesize value = _value;
@synthesize name = _name;

#pragma mark - Lifecycle

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                                   name:(NSString __nonnull *) name {
    self = [super init];
    if (self) {
        _name = name;
        _context = context;
        _valueClass = valueClass;
    }
    return self;
}

-(void) resolve {
    [self doesNotRecognizeSelector:_cmd];
}

-(nonnull id) instantiate {
    
    // Get the value and store it if we are not a factory.
    id newValue = [self resolveValue];
    if (!_factory) {
        _value = newValue;
    }
    return newValue;
}

-(BOOL) createOnStartup {
    return _createOnStartup && _value == nil;
}

-(nullable id) resolveValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
