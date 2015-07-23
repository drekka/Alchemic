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
#import "ALCDefaultValueResolver.h"
#import "ALCModel.h"
#import "ALCClassRegistrationMacroProcessor.h"
#import "ALCInitializerMacroProcessor.h"
#import "ALCMethodMacroProcessor.h"
#import "ALCVariableDependencyMacroProcessor.h"

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
		_valueResolver = [[ALCDefaultValueResolver alloc] init];
	}
	return self;
}

#pragma mark - Initialisation

-(void) start {

	STLog(ALCHEMIC_LOG, @"Starting Alchemic ...");
	[self resolveBuilderDependencies];

	STLog(ALCHEMIC_LOG, @"Creating singletons ...");
	[self instantiateSingletons];
}

#pragma mark - Dependencies

-(void) injectDependencies:(id) object {
	STStartScope([object class]);
	STLog([object class], @">>> Starting dependency injection of a %@ ...", NSStringFromClass([object class]));
	NSSet<id<ALCModelSearchExpression>> *expressions = [ALCRuntime searchExpressionsForClass:[object class]];
	NSSet<ALCClassBuilder *> *builders = [_model classBuildersFromBuilders:[_model buildersForSearchExpressions:expressions]];
	[[builders anyObject] injectObjectDependencies:object];
}

-(void) resolveBuilderDependencies {
	STLog(ALCHEMIC_LOG, @"Resolving dependencies in %lu builders ...", _model.numberBuilders);
	for (id<ALCBuilder> builder in [_model allBuilders]) {
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
	STLog(classBuilder.valueClass, @"Registering a dependency ...");
	Ivar var = [ALCRuntime aClass:classBuilder.valueClass variableForInjectionPoint:variable];
	id<ALCMacroProcessor> macroProcessor = [[ALCVariableDependencyMacroProcessor alloc] initWithVariable:var];
	alc_loadMacrosAfter(macroProcessor, variable);
	[classBuilder addVariableInjection:macroProcessor];
}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... {
	STLog(classBuilder.valueClass, @"Registering a builder ...");
	id<ALCMacroProcessor> macroProcessor = [[ALCClassRegistrationMacroProcessor alloc] init];
	alc_loadMacrosAfter(macroProcessor, classBuilder);
	[classBuilder configureWithMacroProcessor:macroProcessor];
	STLog(classBuilder.valueClass, @"Created: %@, %@", classBuilder, macroProcessor);
}

-(void) registerClassInitializer:(ALCClassBuilder *) classBuilder initializer:(SEL) initializer, ... {
	STLog(classBuilder.valueClass, @"Registering a class initializer for a %@", NSStringFromClass(classBuilder.valueClass));
	id<ALCMacroProcessor> macroProcessor = [[ALCInitializerMacroProcessor alloc] init];
	alc_loadMacrosAfter(macroProcessor, initializer);
	ALCClassInitializerBuilder *initializerBuilder = [[ALCClassInitializerBuilder alloc] initWithValueClass:classBuilder.valueClass];
	initializerBuilder.selector = initializer;
	classBuilder.initializerBuilder = initializerBuilder;
}

-(void) registerMethodBuilder:(ALCClassBuilder *) classBuilder selector:(SEL) selector returnType:(Class) returnType, ... {
	STLog(classBuilder.valueClass, @"Registering a method builder for %@", NSStringFromSelector(selector));
	id<ALCMacroProcessor> macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	alc_loadMacrosAfter(macroProcessor, returnType);
	id<ALCBuilder> methodBuilder = [[ALCMethodBuilder alloc] initWithValueClass:returnType];
	[self addBuilderToModel:methodBuilder];
	[classBuilder addMethodBuilder:methodBuilder];
	STLog(classBuilder.valueClass, @"Created: %@, %@", methodBuilder, macroProcessor);
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

	// This is a two stage process so that all objects are created before dependencies are injected.
	STLog(ALCHEMIC_LOG, @"Instantiating singletons ...");
	NSMutableSet *singletons = [[NSMutableSet alloc] init];
	[[_model allBuilders] enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL *stop) {
		if (builder.createOnBoot) {
			STLog(builder, @"Creating singleton %@ -> %@", builder.name, builder);
			[singletons addObject:builder];
			[builder instantiate];
		}
	}];

	STLog(ALCHEMIC_LOG, @"Injecting dependencies into %lu singletons ...", [singletons count]);
	[singletons enumerateObjectsUsingBlock:^(ALCClassBuilder *singleton, BOOL *stop) {
		[singleton injectObjectDependencies:singleton.value];
	}];

}

@end
