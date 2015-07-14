//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCInitStrategyInjector.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCMethodBuilder.h"
#import "ALCDefaultValueResolver.h"
#import "ALCIsFactory.h"
#import "ALCModel.h"
#import "ALCContext+Internal.h"
#import "ALCInternalMacros.h"

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
    NSSet<ALCQualifier *> *qualifiers = [ALCRuntime qualifiersForClass:[object class]];
    NSSet<ALCClassBuilder *> *builders = [_model classBuildersFromBuilders:[_model buildersForQualifiers:qualifiers]];
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

-(void) registerDependencyInClassBuilder:(ALCClassBuilder *) classBuilder, ... {

    STLog(classBuilder.valueClass, @"Registering a dependency ...");
    NSMutableSet<ALCQualifier *> *qualifiers = [[NSMutableSet alloc] init];
    NSString *intoVariable = nil;

    va_list args;
    va_start(args, classBuilder);
    id arg;
    while ((arg = va_arg(args, id)) != nil) {

        if ([arg isKindOfClass:[ALCIntoVariable class]]) {
            intoVariable = ((ALCIntoVariable *) arg).variableName;

        } else if ([arg isKindOfClass:[ALCQualifier class]]) {
            STLog(classBuilder.valueClass, @"Adding a explicit %@", arg);
            [qualifiers addObject:arg];

        } else {
            @throw [NSException exceptionWithName:@"AlchemicUnexpectedQualifier"
                                           reason:[NSString stringWithFormat:@"Unexpected qualifier %@ for a variable declaration.", arg]
                                         userInfo:nil];
        }
    }
    va_end(args);

    // Add the registration.
    [classBuilder addInjectionPoint:intoVariable withQualifiers:qualifiers];

}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... {

    STLog(classBuilder.valueClass, @"Registering a builder ...");
    Class returnType = NULL;
    BOOL isFactory = NO;
    BOOL isPrimary = NO;
    SEL selector = NULL;
    NSString *name;
    NSMutableArray *qualifiers = [[NSMutableArray alloc] init];

    va_list args;
    va_start(args, classBuilder);
    id arg;
    while ((arg = va_arg(args, id)) != nil) {

        // Now sort out what sort of qualifier we are dealing with.
        if ([arg isKindOfClass:[ALCReturnType class]]) {
            returnType = ((ALCReturnType *)arg).returnType;

        } else if ([arg isKindOfClass:[ALCIntoVariable class]]) {
            @throw [NSException exceptionWithName:@"AlchemicCannotUseIntoVariableHere"
                                           reason:[NSString stringWithFormat:@"Cannot use %@ in a class declaration", arg]
                                         userInfo:nil];

        } else if ([arg isKindOfClass:[ALCIsFactory class]]) {
            isFactory = YES;

        } else if ([arg isKindOfClass:[ALCIsPrimary class]]) {
            isPrimary = YES;

        } else if ([arg isKindOfClass:[ALCAsName class]]) {
            name = ((ALCAsName *) arg).asName;

        } else if ([arg isKindOfClass:[ALCMethodSelector class]]) {
            selector = ((ALCMethodSelector *) arg).factorySelector;

        } else if ([arg isKindOfClass:[ALCQualifier class]]
                   || [arg isKindOfClass:[NSArray class]]) {
            [qualifiers addObject:arg];
        }

    }
    va_end(args);

    // Add the registration.
    id<ALCBuilder> finalBuilder = classBuilder;
    if (selector != NULL) {
        // Dealing with a factory method registration so create a new entry in the model for the method.
        [ALCRuntime aClass:classBuilder.valueClass validateSelector:selector];
        NSString *builderName = [NSString stringWithFormat:@"-[%@ %@]", NSStringFromClass(classBuilder.valueClass), NSStringFromSelector(selector)];
        STLog(classBuilder.valueClass, @"Creating a factory builder for selector %@", builderName);
        finalBuilder = [[ALCMethodBuilder alloc] initWithContext:self
                                                      valueClass:returnType
                                                            name:builderName
                                              parentClassBuilder:classBuilder
                                                        selector:selector
                                                      qualifiers:qualifiers];
        [self addBuilderToModel:finalBuilder];
    }

    if (name != nil) {
        finalBuilder.name = name;
    }
    finalBuilder.factory = isFactory;
    finalBuilder.primary = isPrimary;
    finalBuilder.createOnStartup = !isFactory;

    STLog(classBuilder.valueClass, @"Created: %@, Name: %@, Primary: %@, Factory: %@, Factory Selector: %s returns a %s",
          finalBuilder,
          finalBuilder.name,
          isPrimary ? @"YES": @"NO",
          isFactory ? @"YES": @"NO",
          sel_getName(selector),
          class_getName(returnType));

}

-(void) addBuilderToModel:(id<ALCBuilder> __nonnull) builder {
    [_model addBuilder:builder];
}

-(void) executeOnBuildersWithQualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers
                processingBuildersBlock:(ProcessBuilderBlock __nonnull) processBuildersBlock {
    NSSet<id<ALCBuilder>> *builders = [_model buildersForQualifiers:qualifiers];
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
