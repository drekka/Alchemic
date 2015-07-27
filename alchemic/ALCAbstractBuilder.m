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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractBuilder

// Properties from protocol
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize createOnBoot = _createOnBoot;
@synthesize value = _value;
@synthesize name = _name;

#pragma mark - Lifecycle

-(id) value {
	// Value will be populated if this is not a factory.
	if (_value == nil) {
		STLog(self, @"Value is nil, creating a new value ...");
		id newValue = [self instantiate];
		[self injectObjectDependencies:newValue];
		return newValue;
	} else {
		STLog(self, @"Value present, returning a %@", NSStringFromClass([_value class]));
		return _value;
	}
}

-(id) instantiate {
	id newValue = [self instantiateObject];
	if (!_factory) {
		// Only store the value if this is not a factory.
		STLog(self, @"Created object is a %@ singleton, storing reference", NSStringFromClass([newValue class]));
		_value = newValue;
	}
	return newValue;
}

-(void) configureWithMacroProcessor:(nonnull id<ALCMacroProcessor>)macroProcessor {
}

-(void) validateClass:(Class) aClass selector:(nonnull SEL)selector macroProcessor:(nonnull id<ALCMacroProcessor>)macroProcessor {

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

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors {
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

NS_ASSUME_NONNULL_END
