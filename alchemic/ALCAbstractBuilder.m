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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractBuilder

// Properties from protocol
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize createOnBoot = _createOnBoot;
@synthesize value = _value;
@synthesize name = _name;
@synthesize macroProcessor = _macroProcessor;

#pragma mark - Lifecycle

-(instancetype) init {
	self = [super init];
	if (self) {
		_dependencies = [[NSMutableArray alloc] init];
	}
	return self;
}

-(id) value {
	// Value will be populated if this is not a factory.
	if (_value != nil) {
		STLog(self, @"Value present, returning a %@", NSStringFromClass([_value class]));
		return _value;
	}

	STLog(self, @"Value is nil, creating a new value ...");
	id newValue = [self instantiateObject];
	[self injectValueDependencies:newValue];

	if (!_factory) {
		// Only store the value if this is not a factory.
		STLog(self, @"Created object is a %@ singleton, storing reference", NSStringFromClass([newValue class]));
		_value = newValue;
	}

	return newValue;
}

-(void) validateClass:(Class) aClass selector:(SEL)selector macroProcessor:(ALCMacroProcessor *) macroProcessor {

	if (! [aClass instancesRespondToSelector:selector]) {
		@throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
												 reason:[NSString stringWithFormat:@"Failed to find selector -[%@ %@]", NSStringFromClass(aClass), NSStringFromSelector(selector)]
											  userInfo:nil];
	}

	Method method = class_getInstanceMethod(aClass, selector);
	unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
	if (nbrArgs != [macroProcessor valueSourceCount]) {
		@throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
												 reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
															class_getName(aClass),
															sel_getName(selector),
															nbrArgs,
															[macroProcessor valueSourceCount]]
											  userInfo:nil];
	}
}

-(void) injectValueDependencies:(id) value {
	STLog([value class], @"Injecting %lu dependencies into a %s instance", [_dependencies count], object_getClassName(value));
	for (ALCVariableDependency *dependency in _dependencies) {
		[dependency injectInto:value];
	}
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors {

	if ([_dependencies count] == 0) {
		STLog(self, @"No dependencies found.");
		return;
	}

	for(ALCDependency *dependency in _dependencies) {
		[dependency resolveWithPostProcessors:postProcessors];
	};
}

#pragma mark - Overridable points

-(void) configure {
	self.factory = self.macroProcessor.isFactory;
	self.primary = self.macroProcessor.isPrimary;
	self.createOnBoot = !self.factory;
}

-(id) instantiateObject {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end

NS_ASSUME_NONNULL_END
