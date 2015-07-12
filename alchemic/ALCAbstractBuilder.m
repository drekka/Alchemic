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
        _name = name == nil ? NSStringFromClass(valueClass) : name;
        _context = context;
        _valueClass = valueClass;
    }
    return self;
}

-(BOOL) createOnStartup {
    return _createOnStartup && _value == nil;
}

-(id) value {
    // Value will be populated if this is not a factory.
    if (_value == nil) {
        STLog(_valueClass, @"Value is nil, instantiating a %@ ...", NSStringFromClass(_valueClass));
        id newValue = [self instantiate];
        [self injectObjectDependencies:newValue];
        return newValue;
    } else {
        STLog(_valueClass, @"Value present, returning a %@", NSStringFromClass([_value class]));
        return _value;
    }

}

-(nonnull id) instantiate {
    id newValue = [self instantiateObject];
    if (!_factory) {
        // Only store the value if this is not a factory.
        STLog(_valueClass, @"Created object is a %s singleton, storing reference", class_getName([newValue class]));
        _value = newValue;
    }
    return newValue;
}

-(void) resolveDependencies {
    [self doesNotRecognizeSelector:_cmd];
}

-(nonnull id) instantiateObject {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) injectObjectDependencies:(id) object {
    [self doesNotRecognizeSelector:_cmd];
}

@end
