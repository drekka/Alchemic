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
@synthesize valueClass = _valueClass;
@synthesize primary = _primary;
@synthesize factory = _factory;
@synthesize createOnBoot = _createOnBoot;
@synthesize value = _value;
@synthesize name = _name;

#pragma mark - Lifecycle

-(instancetype) init {
	return nil;
}

-(instancetype) initWithValueClass:(Class)valueClass {
	self = [super init];
	if (self) {
		_valueClass = valueClass;
	}
	return self;
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

-(id) instantiate {
	id newValue = [self instantiateObject];
	if (!_factory) {
		// Only store the value if this is not a factory.
		STLog(_valueClass, @"Created object is a %@ singleton, storing reference", NSStringFromClass([newValue class]));
		_value = newValue;
	}
	return newValue;
}

-(void) configureWithMacroProcessor:(nonnull id<ALCMacroProcessor>)macroProcessor {
}

-(void) validateSelector:(SEL) selector {
	if (! [self.valueClass respondsToSelector:selector]) {
		@throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
												 reason:[NSString stringWithFormat:@"Failed to find selector -[%@ %@]", NSStringFromClass(self.valueClass), NSStringFromSelector(selector)]
											  userInfo:nil];
	}
}

-(void) validateArgumentsForSelector:(nonnull SEL)selector macroProcessor:(nonnull id<ALCMacroProcessor>)macroProcessor {
	Method method = class_getInstanceMethod(self.valueClass, selector);
	unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
	if (nbrArgs != [macroProcessor valueSourceCount]) {
		@throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
												 reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
															class_getName(self.valueClass),
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
