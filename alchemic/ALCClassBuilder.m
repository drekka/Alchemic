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
#import "ALCVariableDependencyMacroProcessor.h"
#import "ALCClassRegistrationMacroProcessor.h"
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

-(instancetype) initWithValueClass:(__unsafe_unretained _Nonnull Class) valueClass {
	self = [super init];
	if (self) {
		_valueClass = valueClass;
		_methodBuilders = [[NSMutableSet alloc] init];
	}
	return self;
}

-(void) configureWithMacroProcessor:(nonnull id<ALCMacroProcessor>)macroProcessor {
	[super configureWithMacroProcessor:macroProcessor];
	ALCClassRegistrationMacroProcessor *processor = macroProcessor;
	self.factory = processor.isFactory;
	self.primary = processor.isPrimary;
	NSString *name = processor.asName;
	self.name = name == nil ? NSStringFromClass(self.valueClass) : name;
	self.createOnBoot = !self.factory;
}

#pragma mark - Adding dependencies

-(void) addVariableInjection:(nonnull ALCVariableDependencyMacroProcessor *)variableMacroProcessor {
	[self.dependencies addObject:[[ALCVariableDependency alloc] initWithVariable:variableMacroProcessor.variable
																						  valueSource:[[variableMacroProcessor valueSourceFactoryForIndex:0] valueSource]]];
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

#pragma mark - Instantiating

-(nonnull id) instantiateObject {

	if (_initializerBuilder != nil) {
		return [_initializerBuilder instantiate];
	}

	STLog(self.valueClass, @"Creating a %@", NSStringFromClass(self.valueClass));
	return [[self.valueClass alloc] init];
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Class %@ for type %s", self.factory ? @"factory" : @"builder", class_getName(self.valueClass)];
}

@end
