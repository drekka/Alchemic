//
//  ALCModelObject.m
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//
@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCAbstractBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCVariableDependency.h"
#import "ALCInternalMacros.h"
#import "AlchemicAware.h"
#import "NSObject+ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractBuilder

#pragma mark - Properties

// Properties from protocol
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize createOnBoot = _createOnBoot;
@synthesize name = _name;
@synthesize macroProcessor = _macroProcessor;
@synthesize available = _available;
@synthesize dependenciesAvailable = _dependenciesAvailable;
@synthesize value = _value;
@synthesize valueClass = _valueClass;

#pragma mark - Lifecycle

-(void) dealloc {
    [self kvoRemoveWatchAvailableFromResolvables:[NSSet setWithArray:self.dependencies]];
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)createOnBoot {
    // This allows for when a dependency as caused a object to be created during the singleton startup process.
    return _createOnBoot
    && _value == nil
    && !_external;
}

-(void) configure {
    self.factory = self.macroProcessor.isFactory;
    self.primary = self.macroProcessor.isPrimary;
    self.createOnBoot = !self.factory;
    NSString *name = self.macroProcessor.asName;
    if (name != nil) {
        self.name = name;
    }
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    // Check for circular dependencies
    STLog(self.valueClass, @"Validating %@", self);

    if ([dependencyStack containsObject:self]) {
        [dependencyStack addObject:self];
        @throw [NSException exceptionWithName:@"AlchemicCircularDependency"
                                       reason:[NSString stringWithFormat:@"Circular dependency detected: %@",
                                               [dependencyStack componentsJoinedByString:@" -> "]]
                                     userInfo:nil];
    }

    [dependencyStack addObject:self];
    for(ALCDependency *dependency in _dependencies) {
        STLog(self, @"Resolving dependency %@", dependency);
        [dependency resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    };

    // remove ourselves before we fall back.
    [dependencyStack removeObject:self];

    _dependenciesAvailable = [self checkDependenciesAvailable];
    _available = _dependenciesAvailable && !_external;

}

-(id) instantiate {

    if (self.external) {
        @throw [NSException exceptionWithName:@"AlchemicValueNotSet"
                                       reason:@"Builder is marked as external but does not have a value yet"
                                     userInfo:nil];
    }

    id newValue = [self instantiateObject];
    if (!self.factory) {
        // Only store the value if this is not a factory.
        STLog(self, @"Caching a %@", NSStringFromClass([newValue class]));
        _value = newValue;
    }
    return newValue;
}

-(id) instantiateObject {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)injectDependencies:(id) value {
    [self doesNotRecognizeSelector:_cmd];
}

-(BOOL) checkDependenciesAvailable {
    for (ALCDependency *dependency in self.dependencies) {
        if (!dependency.available) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Descriptions

-(NSString *) stateDescription {
    return self.valuePresent ? @"* " : @"  ";
}

-(NSString *) attributesDescription {
    return self.factory ? @" (factory)" : @"";
}

#pragma mark - Accessing the value

-(bool) valuePresent {
    return _value != nil;
}

-(void) setValue:(id)value {
    if (self.factory) {
        @throw [NSException exceptionWithName:@"AlchemicCannotSetValueOnFactory"
                                       reason:@"Cannot set a value on a factory builder"
                                     userInfo:nil];
    }

    if (!self.dependenciesAvailable) {
        @throw [NSException exceptionWithName:@"AlchemicDependenciesNotAvailable"
                                       reason:@"Cannot set a value when dependencies are not available to be injected."
                                     userInfo:nil];
    }

    // Set, update value and state and trigger KVOs.
    [self willChangeValueForKey:@"value"];
    _value = value;
    [self injectDependencies:_value];
    [self didChangeValueForKey:@"value"];
    self.available = YES;
}

-(id) value {

    // Value will be populated if this is not a factory.
    if (self.valuePresent) {
        STLog(self, @"Returning a %@", NSStringFromClass([_value class]));
        return _value;
    }

    if (self.external) {
        @throw [NSException exceptionWithName:@"AlchemicCannotCreateValue"
                                       reason:[NSString stringWithFormat:@"%@ Builder is marked as External. Expects an object to be set, not instantiated.", self]
                                     userInfo:nil];
    }

    STLog(self.valueClass, @"Instanting %@ ...", self);
    id newValue = [self instantiate];
    [self injectDependencies:newValue];
    return newValue;
}

-(void) observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *,id> *)change
                       context:(nullable void *)context {

    STLog(self, @"Dependency changed availability");
    if ([self checkDependenciesAvailable]) {

        _dependenciesAvailable = YES; // Trigger KVO.
        if (self.external) {
            if (! self.factory) {
                // Only if it's not a factory do we instantiate.
                [self value];
            }
        } else {
            self.available = YES; // Become available if we are not external which means we will not have a value yet.
        }
    }
}

@end

NS_ASSUME_NONNULL_END
