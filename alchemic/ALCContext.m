//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import <Alchemic/Alchemic.h>
#import "ALCInitStrategyInjector.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCMethodBuilder.h"
#import "ALCDefaultValueResolver.h"
#import "ALCModel.h"
#import "ALCClassRegistrationMacroProcessor.h"
#import "ALCMethodRegistrationMacroProcessor.h"
#import "ALCVariableDependencyMacroProcessor.h"

#define loadMacroProcessor(processorVar, lastArg) \
va_list args; \
va_start(args, lastArg); \
id arg; \
while ((arg = va_arg(args, id)) != nil) { \
[processorVar addArgument:arg]; \
} \
va_end(args); \
[processorVar validate]

@interface ALCContext ()
@property (nonatomic, strong) id<ALCValueResolver> valueResolver;
@end

@implementation ALCContext {
    ALCModel *_model;
    NSMutableSet<Class> *_initialisationStrategyClasses;
    NSSet<id<ALCDependencyPostProcessor>> *_dependencyPostProcessors;
    NSSet<id<ALCObjectFactory>> *_objectFactories;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        _model = [[ALCModel alloc] init];
        _initialisationStrategyClasses = [[NSMutableSet alloc] init];
        _dependencyPostProcessors = [[NSMutableSet alloc] init];
        _objectFactories = [[NSMutableSet alloc] init];
        _valueResolver = [[ALCDefaultValueResolver alloc] init];
    }
    return self;
}

#pragma mark - Initialisation

-(void) start {

    STLog(ALCHEMIC_LOG, @"Starting Alchemic ...");

    // Set defaults.
    if (self.runtimeInitInjector == nil) {
        self.runtimeInitInjector = [[ALCInitStrategyInjector alloc] initWithStrategyClasses:_initialisationStrategyClasses];
    }

    // Inject init wrappers into classes that have registered for dependency injection.
    //[_runtimeInitInjector replaceInitsInModelClasses:_model];

    [self resolveBuilderDependencies];

    STLog(ALCHEMIC_LOG, @"Creating singletons ...");
    [self instantiateSingletons];
}

#pragma mark - Dependencies

-(void) injectDependencies:(id) object {
    STStartScope([object class]);
    STLog([object class], @"Injecting dependencies into a %@", NSStringFromClass([object class]));
    NSSet<id<ALCModelSearchExpression>> *qualifiers = [ALCRuntime searchExpressionsForClass:[object class]];
    NSSet<ALCClassBuilder *> *builders = [_model classBuildersFromBuilders:[_model buildersForSearchExpressions:qualifiers]];
    ALCClassBuilder *classBuilder = [builders anyObject];
    [classBuilder injectObjectDependencies:object];
}

-(void) resolveBuilderDependencies {
    STLog(ALCHEMIC_LOG, @"Resolving dependencies in %lu builders ...", _model.numberBuilders);
    [[_model allBuilders] enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL *stop){
        STLog(builder.valueClass, @"Resolving dependencies for builder %1$@", builder.name);
        STStartScope(builder.valueClass);
        [builder resolveDependenciesWithPostProcessors:self->_dependencyPostProcessors];
    }];
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

-(void) addInitStrategy:(Class) initialisationStrategyClass {
    STLog(ALCHEMIC_LOG, @"Adding init strategy: %s", object_getClassName(initialisationStrategyClass));
    [_initialisationStrategyClasses addObject:initialisationStrategyClass];
}

#pragma mark - Registration call backs

-(void) registerDependencyInClassBuilder:(ALCClassBuilder *) classBuilder variable:(NSString *) variable, ... {

    STLog(classBuilder.valueClass, @"Registering a dependency ...");
    ALCVariableDependencyMacroProcessor *macroProcessor = [[ALCVariableDependencyMacroProcessor alloc] initWithParentClass:classBuilder.valueClass variable:variable];

    loadMacroProcessor(macroProcessor, variable);

    // Add the registration.
    [classBuilder addInjectionPointForArguments:macroProcessor];
}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... {

    STLog(classBuilder.valueClass, @"Registering a builder ...");

    ALCClassRegistrationMacroProcessor *macroProcessor = [[ALCClassRegistrationMacroProcessor alloc] initWithParentClass:classBuilder.valueClass];

    loadMacroProcessor(macroProcessor, classBuilder);

    if (macroProcessor.asName != nil) {
        classBuilder.name = macroProcessor.asName;
    }
    classBuilder.factory = macroProcessor.isFactory;
    classBuilder.primary = macroProcessor.isPrimary;
    classBuilder.createOnStartup = !macroProcessor.isFactory;

    STLog(classBuilder.valueClass, @"Created: %@, %@", classBuilder, macroProcessor);

}

-(void) registerMethodBuilder:(ALCClassBuilder *) classBuilder selector:(SEL) selector returnType:(Class) returnType, ... {

    STLog(classBuilder.valueClass, @"Registering a builder ...");

    ALCMethodRegistrationMacroProcessor *macroProcessor = [[ALCMethodRegistrationMacroProcessor alloc] initWithParentClass:classBuilder.valueClass
                                                                                                                  selector:selector
                                                                                                                returnType:returnType];

    loadMacroProcessor(macroProcessor, returnType);

    // Add the registration.
    // Dealing with a factory method registration so create a new entry in the model for the method.
    NSString *builderName = [NSString stringWithFormat:@"-[%@ %@]", NSStringFromClass(classBuilder.valueClass), NSStringFromSelector(macroProcessor.selector)];
    STLog(classBuilder.valueClass, @"Creating a factory builder for selector %@", builderName);
    id<ALCBuilder> methodBuilder = [[ALCMethodBuilder alloc] initWithParentClassBuilder:classBuilder arguments:macroProcessor];
    [self addBuilderToModel:methodBuilder];
    if (macroProcessor.asName != nil) {
        methodBuilder.name = macroProcessor.asName;
    }
    methodBuilder.factory = macroProcessor.isFactory;
    methodBuilder.primary = macroProcessor.isPrimary;
    methodBuilder.createOnStartup = !macroProcessor.isFactory;

    STLog(classBuilder.valueClass, @"Created: %@, %@", methodBuilder, macroProcessor);

}

-(void) addBuilderToModel:(id<ALCBuilder> __nonnull) builder {
    [_model addBuilder:builder];
}

-(void) executeOnBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
                       processingBuildersBlock:(ProcessBuilderBlock) processBuildersBlock {
    NSSet<id<ALCBuilder>> *builders = [_model buildersForSearchExpressions:searchExpressions];
    if ([builders count] > 0) {
        processBuildersBlock(builders);
    }
}

#pragma mark - Objects

-(nonnull id) instantiateObjectFromBuilder:(id<ALCBuilder> __nonnull) builder {

    for (id<ALCObjectFactory> objectFactory in _objectFactories) {
        id newValue = [objectFactory createObjectFromBuilder:builder];
        if (newValue != nil) {
            return newValue;
        }
    }

    // Trigger an exception if we don't create anything.
    @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                   reason:[NSString stringWithFormat:@"Unable to create an instance of %@", [builder description]]
                                 userInfo:nil];

}

#pragma mark - Internal

-(void) instantiateSingletons {

    // This is a two stage process so that all objects are created before dependencies are injected.
    STLog(ALCHEMIC_LOG, @"Instantiating singletons ...");
    NSMutableSet *singletons = [[NSMutableSet alloc] init];
    [[_model allClassBuilders] enumerateObjectsUsingBlock:^(ALCClassBuilder *classBuilder, BOOL *stop) {
        if (classBuilder.createOnStartup) {
            STLog(classBuilder, @"Creating singleton %@ -> %@", classBuilder.name, classBuilder);
            [singletons addObject:classBuilder];
            [classBuilder instantiate];
        }
    }];

    STLog(ALCHEMIC_LOG, @"Injecting dependencies into %lu singletons ...", [singletons count]);
    [singletons enumerateObjectsUsingBlock:^(ALCClassBuilder *singleton, BOOL *stop) {
        [singleton injectObjectDependencies:singleton.value];
    }];
    
}

@end
