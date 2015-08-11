//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCContext.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCClassInitializerBuilder.h"
#import "ALCInternalMacros.h"
#import "ALCMethodBuilder.h"
#import "ALCModel.h"
#import "ALCMacroProcessor.h"
#import "ALCDependency.h"
#import "ALCValueSourceFactory.h"

@interface ALCContext ()
@property (nonatomic, strong) id<ALCValueResolver> valueResolver;
@end

@implementation ALCContext {
	ALCModel *_model;
	id _appDelegate;
	NSSet<id<ALCDependencyPostProcessor>> *_dependencyPostProcessors;
}

#pragma mark - Lifecycle

-(instancetype) init {
	self = [super init];
	if (self) {
		_appDelegate = [UIApplication sharedApplication].delegate;
		_model = [[ALCModel alloc] init];
		_dependencyPostProcessors = [[NSMutableSet alloc] init];
	}
	return self;
}

#pragma mark - Initialisation

-(void) start {

	STStartScope(ALCHEMIC_LOG);
	STLog(ALCHEMIC_LOG, @"Starting Alchemic ...");
	[self resolveBuilderDependencies];
	STLog(ALCHEMIC_LOG, @"Instantiating singletons ...");
	[self instantiateSingletons];
	STLog(ALCHEMIC_LOG, @"Alchemic started.");
}

#pragma mark - Dependencies

-(void) injectDependencies:(id) object {
	STStartScope(object);
	STLog(object, @"Starting dependency injection of a %@ ...", NSStringFromClass([object class]));
	NSSet<id<ALCModelSearchExpression>> *expressions = [ALCRuntime searchExpressionsForClass:[object class]];
	NSSet<ALCClassBuilder *> *builders = [_model classBuildersFromBuilders:[_model buildersForSearchExpressions:expressions]];
	[[builders anyObject] injectValueDependencies:object];
}

-(void) resolveBuilderDependencies {

	STLog(ALCHEMIC_LOG, @"Resolving dependencies in %lu builders ...", _model.numberBuilders);
	for (id<ALCBuilder> builder in [_model allBuilders]) {
		STLog(builder.valueClass, @"Resolving dependencies in %@", builder);
		STStartScope(builder.valueClass);
		[builder resolveWithPostProcessors:self->_dependencyPostProcessors];
	}

	STLog(ALCHEMIC_LOG, @"Validating dependencies in %lu builders ...", _model.numberBuilders);
	for (id<ALCBuilder> builder in [_model allBuilders]) {
		NSMutableArray<id<ALCResolvable>> *stack = [[NSMutableArray alloc] init];
		[builder validateWithDependencyStack:stack];
	}

}

#pragma mark - Configuration

-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor {
	STLog(ALCHEMIC_LOG, @"Adding dependency post processor: %s", object_getClassName(postProcessor));
	[(NSMutableSet *)_dependencyPostProcessors addObject:postProcessor];
}

#pragma mark - Registration call backs

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder variableDependency:(NSString *) variable, ... {

	STLog(classBuilder.valueClass, @"Registering variable dependency %@.%@ ...", NSStringFromClass(classBuilder.valueClass), variable);

	Ivar var = [ALCRuntime aClass:classBuilder.valueClass variableForInjectionPoint:variable];
	ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosValueDef];
	alc_loadMacrosAfter(macroProcessor, variable);

	// Add a default value source for the ivar if no macros where loaded to define it.
	if ([macroProcessor valueSourceCount] == 0) {
		NSSet<id<ALCModelSearchExpression>> *macros = [ALCRuntime searchExpressionsForVariable:var];
		for (id<ALCModelSearchExpression> macro in macros) {
			[macroProcessor addMacro:(id<ALCMacro>)macro];
		}
	}

	[classBuilder addVariableInjection:var macroProcessor:macroProcessor];
}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... {
	STLog(classBuilder.valueClass, @"Updating the current class builder ...");
	alc_loadMacrosAfter(classBuilder.macroProcessor, classBuilder);
	[classBuilder configure];
	STLog(classBuilder.valueClass, @"Modified builder: %@, %@", classBuilder, classBuilder.macroProcessor);
}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder initializer:(SEL) initializer, ... {
	STLog(classBuilder.valueClass, @"Registering a class initializer for a %@", NSStringFromClass(classBuilder.valueClass));
	ALCClassInitializerBuilder *initializerBuilder = [[ALCClassInitializerBuilder alloc] initWithParentClassBuilder:classBuilder selector:initializer];
	alc_loadMacrosAfter(initializerBuilder.macroProcessor, initializer);
	[initializerBuilder configure];

	// replace the class builder in the model with the initializer builder because now we have an initializer we don't want the class to be found as the source of these objects.
	[_model addBuilder:initializerBuilder];
	[_model removeBuilder:classBuilder];

}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder selector:(SEL) selector returnType:(Class) returnType, ... {
	STLog(classBuilder.valueClass, @"Registering a method builder for %@", NSStringFromSelector(selector));
	ALCMethodBuilder *methodBuilder = [[ALCMethodBuilder alloc] initWithParentBuilder:classBuilder
																									 selector:selector
																								  valueClass:returnType];
	alc_loadMacrosAfter(methodBuilder.macroProcessor, returnType);
	[methodBuilder configure];
	[_model addBuilder:methodBuilder];
	STLog(classBuilder.valueClass, @"Created: %@, %@", methodBuilder, methodBuilder.macroProcessor);
}

-(void) addBuilderToModel:(id<ALCBuilder> _Nonnull) builder {

	// Look for the all delegate builder and set it.
	if ([builder.valueClass isSubclassOfClass:[_appDelegate class]]) {
		builder.value = _appDelegate;
	}
	[_model addBuilder:builder];
}

-(void) executeOnBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
							  processingBuildersBlock:(ProcessBuilderBlock) processBuildersBlock {
	NSSet<id<ALCBuilder>> *builders = [_model buildersForSearchExpressions:searchExpressions];
	if ([builders count] > 0) {
		processBuildersBlock(builders);
	}
}

#pragma mark - Retrieveing objects

-(id) getValueWithClass:(Class) returnType, ... {

	ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosValueDef];
	alc_loadMacrosAfter(macroProcessor, returnType);

	// Analyse the return type if no macros where loaded to define it.
	if ([macroProcessor valueSourceCount] == 0) {
		NSSet<id<ALCModelSearchExpression>> *macros = [ALCRuntime searchExpressionsForClass:returnType];
		for (id<ALCModelSearchExpression> macro in macros) {
			[macroProcessor addMacro:(id<ALCMacro>)macro];
		}
	}

	ALCDependency *dependency = [[ALCDependency alloc] initWithValueClass:returnType
																				 valueSource:[[macroProcessor valueSourceFactoryAtIndex:0] valueSource]];
	[dependency resolveWithPostProcessors:_dependencyPostProcessors];
	[dependency validateWithDependencyStack:[NSMutableArray array]];
	return dependency.value;
}

#pragma mark - Internal

-(void) instantiateSingletons {

	// This is a two stage process so that all objects are created before dependencies are injected. This helps with defeating circular dependency issues.

	// Use a map table so we can store keys without copying them.
	//NSMapTable<id, id<ALCBuilder>> *singletons = [NSMapTable strongToStrongObjectsMapTable];
	for (id<ALCBuilder> builder in [_model allBuilders]) {
		if (builder.createOnBoot) {
			STLog(builder, @"Creating singleton '%@' using %@", builder.name, builder);
			//id obj =
			[builder instantiate];
			//[singletons setObject:builder forKey:obj];
		}
	};

	STLog(ALCHEMIC_LOG, @"Injecting dependencies ...");
	//	STLog(ALCHEMIC_LOG, @"Injecting dependencies into %lu singletons ...", [singletons count]);
	for (id<ALCBuilder> builder in [_model allBuilders]) {
		[builder inject];
	}
	//for (id obj in [singletons keyEnumerator]) {
	//	id<ALCBuilder> builder = [singletons objectForKey:obj];
	//	[builder injectValueDependencies:obj];
	//}

}

@end
