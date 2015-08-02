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
#import "ALCSearchableBuilder.h"

@interface ALCContext ()
@property (nonatomic, strong) id<ALCValueResolver> valueResolver;
@end

@implementation ALCContext {
	ALCModel *_model;
	NSSet<id<ALCDependencyPostProcessor>> *_dependencyPostProcessors;
	NSSet<id<ALCObjectFactory>> *_objectFactories;
}

#pragma mark - Lifecycle

-(instancetype) init {
	self = [super init];
	if (self) {
		_model = [[ALCModel alloc] init];
		_dependencyPostProcessors = [[NSMutableSet alloc] init];
		_objectFactories = [[NSMutableSet alloc] init];
	}
	return self;
}

#pragma mark - Initialisation

-(void) start {

	STStartScope(ALCHEMIC_LOG);
	STLog(ALCHEMIC_LOG, @"Starting Alchemic ...");
	STLog(ALCHEMIC_LOG, @"Resolving dependencies ...");
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
	for (id<ALCSearchableBuilder> builder in [_model allBuilders]) {
		STLog(builder.valueClass, @"Resolving dependencies for builder %@", builder.name);
		STStartScope(builder.valueClass);
		[builder resolveDependenciesWithPostProcessors:self->_dependencyPostProcessors];
	}
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
	STLog(ALCHEMIC_LOG, @"Adding object factory: %s", object_getClassName(objectFactory));
	[(NSMutableSet *)_objectFactories addObject:objectFactory];
}

-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor {
	STLog(ALCHEMIC_LOG, @"Adding dependency post processor: %s", object_getClassName(postProcessor));
	[(NSMutableSet *)_dependencyPostProcessors addObject:postProcessor];
}

#pragma mark - Registration call backs

-(void) registerDependencyInClassBuilder:(ALCClassBuilder *) classBuilder variable:(NSString *) variable, ... {

	STLog(classBuilder.valueClass, @"Registering variable dependency %@ ...", variable);

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
	STLog(classBuilder.valueClass, @"Registering a builder ...");
	alc_loadMacrosAfter(classBuilder.macroProcessor, classBuilder);
	[classBuilder configure];
	STLog(classBuilder.valueClass, @"Created: %@, %@", classBuilder, classBuilder.macroProcessor);
}

-(void) registerClassInitializer:(ALCClassBuilder *) classBuilder initializer:(SEL) initializer, ... {
	STLog(classBuilder.valueClass, @"Registering a class initializer for a %@", NSStringFromClass(classBuilder.valueClass));
	ALCClassInitializerBuilder *initializerBuilder = [classBuilder createInitializerBuilderForSelector:initializer];
	alc_loadMacrosAfter(initializerBuilder.macroProcessor, initializer);
	[initializerBuilder configure];
}

-(void) registerMethodBuilder:(ALCClassBuilder *) classBuilder selector:(SEL) selector returnType:(Class) returnType, ... {
	STLog(classBuilder.valueClass, @"Registering a method builder for %@", NSStringFromSelector(selector));
	ALCMethodBuilder *methodBuilder = [classBuilder createMethodBuilderForSelector:selector valueClass:returnType];
	alc_loadMacrosAfter(methodBuilder.macroProcessor, returnType);
	[methodBuilder configure];
	[self addBuilderToModel:methodBuilder];
	STLog(classBuilder.valueClass, @"Created: %@, %@", methodBuilder, methodBuilder.macroProcessor);
}

-(void) addBuilderToModel:(id<ALCBuilder> _Nonnull) builder {
	[_model addBuilder:builder];
}

-(void) executeOnBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
							  processingBuildersBlock:(ProcessBuilderBlock) processBuildersBlock {
	NSSet<id<ALCBuilder>> *builders = [_model buildersForSearchExpressions:searchExpressions];
	if ([builders count] > 0) {
		processBuildersBlock(builders);
	}
}

#pragma mark - Internal

-(void) instantiateSingletons {

	// This is a two stage process so that all objects are created before dependencies are injected. This helps with defeating circular dependency issues.

	// Use a map table so we can store keys without copying them.
	NSMapTable<id, id<ALCSearchableBuilder>> *singletons = [NSMapTable strongToStrongObjectsMapTable];
	for (id<ALCSearchableBuilder> builder in [_model allBuilders]) {
		if (builder.createOnBoot) {
			STLog(builder, @"Creating singleton '%@' using %@", builder.name, builder);
			id obj = [builder instantiate];
			[singletons setObject:builder forKey:obj];
		}
	};

	STLog(ALCHEMIC_LOG, @"Injecting dependencies into %lu singletons ...", [singletons count]);
	for (id obj in [singletons keyEnumerator]) {
		id<ALCBuilder> builder = [singletons objectForKey:obj];
		[builder injectValueDependencies:obj];
	}

}

@end
