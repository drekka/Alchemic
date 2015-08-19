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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractBuilder

#pragma mark - Properties

// Properties from protocol
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize createOnBoot = _createOnBoot;
@synthesize value = _value;
@synthesize name = _name;
@synthesize macroProcessor = _macroProcessor;
@synthesize resolved = _resolved;
@synthesize valueClass = _valueClass;

#pragma mark - Lifecycle

-(instancetype) init {
	self = [super init];
	if (self) {
		_dependencies = [[NSMutableArray alloc] init];
	}
	return self;
}

-(BOOL)createOnBoot {
    // This allows for when a dependency as caused a object to be created during the singleton startup process.
    return _createOnBoot && _value == nil;
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

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors {

    _resolved = YES;

    if ([_dependencies count] == 0) {
        STLog(self, @"No dependencies found.");
        return;
    }

    for(ALCDependency *dependency in _dependencies) {
        [dependency resolveWithPostProcessors:postProcessors];
    };
}

-(void) validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {

    STLog(self.valueClass, @"Validating %@", self);
    if ([dependencyStack containsObject:self]) {
        [dependencyStack addObject:self];
        @throw [NSException exceptionWithName:@"AlchemicCircularDependency"
                                       reason:[NSString stringWithFormat:@"Circular dependency detected: %@",
                                               [dependencyStack componentsJoinedByString:@" -> "]]
                                     userInfo:nil];
    }

    [dependencyStack addObject:self];
    for (ALCDependency *dependency in _dependencies) {
        [dependency validateWithDependencyStack:dependencyStack];
    }

    // remove ourselves before we fall back.
    [dependencyStack removeObject:self];
    
}

-(id) instantiate {
    id newValue = [self instantiateObject];
    if (!_factory) {
        // Only store the value if this is not a factory.
        STLog(self, @"Caching a %@", NSStringFromClass([newValue class]));
        self.value = newValue;
    }
    return newValue;
}

-(id) instantiateObject {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)inject {
    if (_value != nil) {
        [self injectValueDependencies:_value];
    }
}

-(void) injectValueDependencies:(id) value {
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Descriptions

-(NSString *) stateDescription {
    return _value == nil ? @"  " : @"* ";
}

-(NSString *) attributesDescription {
    return self.factory ? @" - factory" : @"";
}

#pragma mark - Accessing the value

-(id) value {
    // Value will be populated if this is not a factory.
    if (_value == nil) {
        STLog(self.valueClass, @"Instanting %@ ...", self);
        id newValue = [self instantiate];
        [self injectValueDependencies:newValue];
        return newValue;
    } else {
        STLog(self, @"Returning a %@", NSStringFromClass([_value class]));
        return _value;
    }
}


@end

NS_ASSUME_NONNULL_END
