//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassBuilder.h"

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCRuntime.h"
#import "ALCVariableDependency.h"
#import "ALCClassBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCModelValueSource.h"
#import "ALCClassInitializerBuilder.h"
#import "ALCMethodBuilder.h"
#import "ALCValueSourceFactory.h"

@implementation ALCClassBuilder {
	NSMutableSet<ALCMethodBuilder *> *_methodBuilders;
	ALCClassInitializerBuilder *_initializerBuilder;

}

@synthesize valueClass = _valueClass;

-(instancetype) init {
	return nil;
}

-(instancetype) initWithValueClass:(__unsafe_unretained Class) valueClass {
	self = [super init];
	if (self) {
		_valueClass = valueClass;
		_methodBuilders = [[NSMutableSet alloc] init];
		self.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary];
		self.name = NSStringFromClass(valueClass);
	}
	return self;
}

#pragma mark - Configuring

-(void) configure {
	[super configure];
	NSString *name = self.macroProcessor.asName;
	if (name != nil) {
		self.name = name;
	}
}

#pragma mark - Adding dependencies

-(void) addVariableInjection:(Ivar) variable macroProcessor:(ALCMacroProcessor *) macroProcessor {
	[self.dependencies addObject:[[ALCVariableDependency alloc] initWithVariable:variable
																						  valueSource:[[macroProcessor valueSourceFactoryAtIndex:0] valueSource]]];
}

-(ALCClassInitializerBuilder *) createInitializerBuilderForSelector:(SEL) initializer {
	ALCClassInitializerBuilder *builder = [[ALCClassInitializerBuilder alloc] initWithParentClassBuilder:self
																															  selector:initializer];
	_initializerBuilder = builder;
	return builder;
}

-(ALCMethodBuilder *) createMethodBuilderForSelector:(SEL)selector valueClass:(Class) valueClass {
	ALCMethodBuilder *builder = [[ALCMethodBuilder alloc] initWithParentBuilder:self
																							 selector:selector
																						  valueClass:valueClass];
	[_methodBuilders addObject:builder];
	return builder;
}

#pragma mark - resolving

-(void)resolveDependenciesWithPostProcessors:(nonnull NSSet<id<ALCDependencyPostProcessor>> *)postProcessors {
	[super resolveDependenciesWithPostProcessors:postProcessors];
	[_initializerBuilder resolveDependenciesWithPostProcessors:postProcessors];
}

#pragma mark - Instantiating

-(nonnull id) instantiateObject {

	if (_initializerBuilder != nil) {
		return [_initializerBuilder instantiateObject];
	}

	STLog(self.valueClass, @"Creating a %@", NSStringFromClass(self.valueClass));
	return [[self.valueClass alloc] init];
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Class %@ for type %s", self.factory ? @"factory" : @"builder", class_getName(self.valueClass)];
}

@end
