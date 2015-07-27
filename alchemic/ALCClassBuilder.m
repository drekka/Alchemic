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
	NSMutableSet<ALCVariableDependency *> *_dependencies;
	NSMutableSet<ALCMethodBuilder *> *_methodBuilders;
}

@synthesize valueClass = _valueClass;

-(instancetype) init {
	return nil;
}

-(instancetype) initWithValueClass:(__unsafe_unretained _Nonnull Class) valueClass {
	self = [super init];
	if (self) {
		_valueClass = valueClass;
		_dependencies = [[NSMutableSet alloc] init];
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
	[_dependencies addObject:[[ALCVariableDependency alloc] initWithVariable:variableMacroProcessor.variable
																					 valueSource:[[variableMacroProcessor valueSourceFactoryForIndex:0] valueSource]]];
}

-(void) setInitializerBuilder:(ALCClassInitializerBuilder * _Nonnull)initializerBuilder {
	_initializerBuilder = initializerBuilder;
	initializerBuilder.parentClassBuilder = self;
}

-(void) addMethodBuilder:(nonnull ALCMethodBuilder *)methodBuilder {
	[_methodBuilders addObject:methodBuilder];
	methodBuilder.parentClassBuilder = self;
}

#pragma mark - Instantiating

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
	[_dependencies enumerateObjectsUsingBlock:^(ALCVariableDependency *dependency, BOOL *stop) {
		[dependency resolveWithPostProcessors:postProcessors];
	}];
}

-(nonnull id) instantiateObject {
	
	if (self.initializerBuilder != nil) {
		return [self.initializerBuilder instantiate];
	}

	STLog(self.valueClass, @"Creating a %@", NSStringFromClass(self.valueClass));
	return [[self.valueClass alloc] init];
}

-(void) injectObjectDependencies:(id _Nonnull) object {
	STLog([object class], @">>> Injecting %lu dependencies into a %s instance", [_dependencies count], object_getClassName(object));
	for (ALCVariableDependency *dependency in _dependencies) {
		[dependency injectInto:object];
	}
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Class %@ for type %s", self.factory ? @"factory" : @"builder", class_getName(self.valueClass)];
}

@end
