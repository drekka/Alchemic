//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCInternalMacros.h"

#import "ALCContext.h"
#import "ALCRuntime.h"

#import "ALCModel.h"
#import "ALCBuilder.h"
#import "ALCDependency.h"
#import "ALCMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCModelValueSource.h"

#import "ALCBuilderType.h"
#import "ALCClassBuilderType.h"
#import "ALCInitializerBuilderType.h"
#import "ALCMethodBuilderType.h"

#import "ALCClass.h"

#import "NSSet+Alchemic.h"

NSString *const AlchemicFinishedLoading = @"AlchemicFinishedLoading";

@interface ALCContext ()
@property (nonatomic, strong) id<ALCValueResolver> valueResolver;
@end

@implementation ALCContext {
    ALCModel *_model;
    NSSet<id<ALCDependencyPostProcessor>> *_dependencyPostProcessors;
    NSMutableSet<AcSimpleBlock> *_onLoadBlocks;
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _model = [[ALCModel alloc] init];
        _dependencyPostProcessors = [[NSMutableSet alloc] init];
        _onLoadBlocks = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - Initialisation

- (void)start {

    STStartScope(ALCHEMIC_LOG);
    STLog(ALCHEMIC_LOG, @"Starting Alchemic ...");
    [self resolveBuilderDependencies];
    STLog(ALCHEMIC_LOG, @"Finishing startup ...");
    [self finishStartup];
    STLog(ALCHEMIC_LOG, @"Alchemic started.");
}

#pragma mark - Dependencies

- (void)injectDependencies:(id)object {
    STStartScope(object);
    STLog(object, @"Starting dependency injection of a %@ ...", NSStringFromClass([object class]));
    NSSet<id<ALCModelSearchExpression>> *expressions = [ALCRuntime searchExpressionsForClass:[object class]];
    NSSet<ALCBuilder *> *builders = [_model classBuildersFromBuilders:[_model buildersForSearchExpressions:expressions]];
    [[builders anyObject] injectDependencies:object];
}

- (void)resolveBuilderDependencies {
    STLog(ALCHEMIC_LOG, @"Resolving dependencies in %lu builders ...", _model.numberBuilders);
    for (ALCBuilder *builder in [_model allBuilders]) {
        STStartScope(builder.valueClass);
        [builder resolve];
    }
}

#pragma mark - Configuration

- (void)addDependencyPostProcessor:(id<ALCDependencyPostProcessor>)postProcessor {
    STLog(ALCHEMIC_LOG, @"Adding dependency post processor: %s", object_getClassName(postProcessor));
    [(NSMutableSet *)_dependencyPostProcessors addObject:postProcessor];
}

#pragma mark - Registration call backs

-(ALCBuilder *) registerBuilderForClass:(Class) aClass {
    id<ALCBuilderType> builderType = [[ALCClassBuilderType alloc] initWithType:aClass];
    ALCBuilder *classBuilder = [[ALCBuilder alloc] initWithBuilderType:builderType];

    // Turn off the registered flag so that the class builder does not set it until a AcRegister(...) macro is executed.
    // All other builders will be set to YES by default.
    classBuilder.registered = NO;

    [_model addBuilder:classBuilder];
    return classBuilder;
}

-(void) registerClassBuilderProperties:(ALCBuilder *) classBuilder, ... {
    STLog(classBuilder.valueClass, @"Registering class %@", NSStringFromClass(classBuilder.valueClass));

    // turn the registration flag back on so we can create instances.
    classBuilder.registered = YES;

    alc_loadMacrosAfter(classBuilder.macroProcessor, classBuilder);
}

-(void) classBuilderDidFinishRegistering:(ALCBuilder *) classBuilder {
    [classBuilder configure];
}

- (void)registerClassBuilder:(ALCBuilder *)classBuilder variableDependency:(NSString *)variable, ... {

    STStartScope(classBuilder.valueClass);

    Ivar var = [ALCRuntime aClass:classBuilder.valueClass variableForInjectionPoint:variable];
    Class varClass = [ALCRuntime iVarClass:var];
    ALCValueSourceFactory *valueSourceFactory = [[ALCValueSourceFactory alloc] initWithType:varClass];
    alc_loadMacrosAfter(valueSourceFactory, variable);

    // Add a default value source for the ivar if no macros where loaded to define it.
    if ([valueSourceFactory.macros count] == 0) {
        STLog(classBuilder.valueClass, @"Generating search criteria from variable %s", ivar_getName(var));
        NSSet<id<ALCModelSearchExpression>> *macros = [ALCRuntime searchExpressionsForVariable:var];
        for (id<ALCModelSearchExpression> macro in macros) {
            [valueSourceFactory addMacro:(id<ALCMacro>)macro];
        }
    }

    [classBuilder addVariableInjection:var valueSourceFactory:valueSourceFactory];
}

- (void)registerClassBuilder:(ALCBuilder *)classBuilder initializer:(SEL)initializer, ... {
    STLog(classBuilder.valueClass, @"Registering initializer -[%@ %@]", NSStringFromClass(classBuilder.valueClass), NSStringFromSelector(initializer));
    id<ALCBuilderType> builderType = [[ALCInitializerBuilderType alloc] initWithClassBuilder:classBuilder initializer:initializer];
    ALCBuilder *initializerBuilder = [[ALCBuilder alloc] initWithBuilderType:builderType];
    alc_loadMacrosAfter(initializerBuilder.macroProcessor, initializer);
    [initializerBuilder configure];

    // replace the class builder in the model with the initializer builder because now we have an initializer we don't want the class to be found as the source of these objects.
    [_model addBuilder:initializerBuilder];
    [_model removeBuilder:classBuilder];
    STLog(classBuilder.valueClass, @"Created initializer %@", initializerBuilder);
}

- (void)registerClassBuilder:(ALCBuilder *)classBuilder selector:(SEL)selector returnType:(Class)returnType, ... {
    id<ALCBuilderType> builderType = [[ALCMethodBuilderType alloc] initWithType:returnType
                                                                   classBuilder:classBuilder
                                                                       selector:selector];
    STLog(classBuilder.valueClass, @"Registering method -(%@) [%@ %@]", NSStringFromClass(returnType), NSStringFromClass(classBuilder.valueClass), NSStringFromSelector(selector));
    ALCBuilder *methodBuilder = [[ALCBuilder alloc] initWithBuilderType:builderType];
    alc_loadMacrosAfter(methodBuilder.macroProcessor, returnType);
    [methodBuilder configure];
    [_model addBuilder:methodBuilder];
}

- (ALCBuilder *)classBuilderForClass:(Class)aClass {
    NSSet<ALCBuilder *> *builders = [_model buildersForSearchExpressions:[NSSet setWithObject:[ALCClass withClass:aClass]]];
    NSSet<ALCBuilder *> *classBuilders = [_model classBuildersFromBuilders:builders];
    return [classBuilders anyObject];
}

- (void)findBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *)searchExpressions
                  processingBuildersBlock:(ProcessBuilderBlock)processBuildersBlock {
    NSSet<ALCBuilder *> *builders = [_model buildersForSearchExpressions:searchExpressions];
    if ([builders count] > 0) {
        processBuildersBlock(builders);
    }
}

#pragma mark - finished loading

- (void)executeWhenStarted:(AcSimpleBlock)block {

    // if there is no on load set then Alchemic has started and the blocks have either been executed or are in the process of being executed.
    if (_onLoadBlocks == nil) {
        STLog(self, @"Alchemic already started. Executing block immediately");
        block();
        return;
    }

    // Otherwise add to the set.
    [_onLoadBlocks addObject:[block copy]];
}

#pragma mark - Retrieveing objects

- (void)setValue:(id)value inBuilderWith:(id<ALCModelSearchExpression>)searchMacro, ... {

    NSMutableSet<id<ALCModelSearchExpression>> *searchExpressions = [[NSMutableSet alloc] init];
    alc_processVarArgsIncluding(id<ALCModelSearchExpression>, searchMacro, ^(id macro) {
        [searchExpressions addObject:macro];
    });

    NSSet<ALCBuilder *> *builders = [_model buildersForSearchExpressions:searchExpressions];

    if ([builders count] != 1) {
        @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberOfBuilders"
                                       reason:[NSString stringWithFormat:@"Expected 1, but got %lu builders trying to set a value on %@", (unsigned long)[builders count], self]
                                     userInfo:nil];
    }

    [builders anyObject].value = value;
}

- (id)getValueWithClass:(Class)returnType, ... {

    ALCValueSourceFactory *valueSourceFactory = [[ALCValueSourceFactory alloc] initWithType:returnType];
    alc_loadMacrosAfter(valueSourceFactory, returnType);

    // Analyse the return type if no macros where loaded to define it.
    if ([valueSourceFactory.macros count] == 0) {
        NSSet<id<ALCModelSearchExpression>> *macros = [ALCRuntime searchExpressionsForClass:returnType];
        for (id<ALCMacro> macro in macros) {
            [valueSourceFactory addMacro:macro];
        }
    }

    ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSourceFactory.valueSource];
    [dependency.valueSource resolve];
    return dependency.value;
}

- (id)invokeMethodBuilders:(id<ALCModelSearchExpression>)methodLocator, ... {

    NSMutableArray *args = [[NSMutableArray alloc] init];
    alc_processVarArgsAfter(id, methodLocator, ^(id value) {
        [args addObject:value];
    });

    NSSet<ALCBuilder *> *builders = [_model buildersForSearchExpressions:[NSSet setWithObject:methodLocator]];

    NSMutableSet<id> *results = [[NSMutableSet alloc] init];
    [builders enumerateObjectsUsingBlock:^(ALCBuilder *builder, BOOL *stop) {
        if (!builder.isClassBuilder) {
            // We only execute on method or initializer builders.
            [results addObject:[builder invokeWithArgs:args]];
        }
    }];
    return [results count] == 1 ? [results anyObject] : results;
}

#pragma mark - Internal

- (void)finishStartup {

    STLog(ALCHEMIC_LOG, @"Executing finished loading blocks ...");
    // Clear the blocks immediately so we don't risk any synchronization issues with other thread still registering blocks.
    // This will trigger any incoming blocks to execute immediately.
    NSMutableSet<AcSimpleBlock> *blocks;
    @synchronized(_onLoadBlocks) {
        blocks = _onLoadBlocks;
        _onLoadBlocks = nil;
    }

    // This could take some time so we keep it out of the sync block.
    for (AcSimpleBlock block in blocks) {
        // Put back on main queue.
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }

    // Send a final notification.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicFinishedLoading object:self];
    });

    STLog(ALCHEMIC_LOG, @"Registered model builders (* - instantiated):...\n%@\n", _model);
}

@end
