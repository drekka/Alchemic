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
#import "ALCDefaultValueResolverManager.h"
#import "ALCIsFactory.h"
#import "ALCModel.h"
#import "ALCContext+Internal.h"
#import "ALCinternal.h"

@implementation ALCContext {
    ALCModel *_model;
    NSDictionary<NSString *, id<ALCBuilder>> *model;
    NSMutableSet<Class> *_initialisationStrategyClasses;
    NSSet<id<ALCDependencyPostProcessor>> *_dependencyPostProcessors;
    NSSet<id<ALCObjectFactory>> *_objectFactories;
    id<ALCValueResolverManager> _valueResolverManager;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        _model = [[ALCModel alloc] init];
        _initialisationStrategyClasses = [[NSMutableSet alloc] init];
        _dependencyPostProcessors = [[NSMutableSet alloc] init];
        _objectFactories = [[NSMutableSet alloc] init];
        _valueResolverManager = [[ALCDefaultValueResolverManager alloc] init];
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

-(void) injectDependencies:(id) object {
    NSSet<ALCQualifier *> *qualifiers = [ALCRuntime qualifiersForClass:[object class]];
    NSSet<ALCClassBuilder *> *builders = [_model classBuildersFromBuilders:[_model buildersMatchingQualifiers:qualifiers]];
    ALCClassBuilder *classBuilder = [builders anyObject];
    [classBuilder injectDependenciesInto:object];
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

    NSMutableSet<ALCQualifier *> *qualifiers = [[NSMutableSet alloc] init];
    NSString *intoVariable = nil;

    va_list args;
    va_start(args, classBuilder);
    id arg;
    while ((arg = va_arg(args, id)) != nil) {

        if ([arg isKindOfClass:[ALCIntoVariable class]]) {
            intoVariable = ((ALCIntoVariable *) arg).variableName;

        } else if ([arg isKindOfClass:[ALCQualifier class]]) {
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
        [ALCRuntime validateSelector:selector withClass:classBuilder.valueClass];
        NSString *finalName = name == nil ? [NSString stringWithFormat:@"%@::%@", NSStringFromClass(returnType), NSStringFromSelector(selector)]: name;
        finalBuilder = [[ALCMethodBuilder alloc] initWithContext:self
                                                      valueClass:returnType
                                                            name:finalName
                                              parentClassBuilder:classBuilder
                                                        selector:selector
                                                      qualifiers:qualifiers];
        [self addBuilderToModel:finalBuilder];
    }

    finalBuilder.factory = isFactory;
    finalBuilder.primary = isPrimary;
    finalBuilder.createOnStartup = !isFactory;

    STLog(finalBuilder, @"Setting up: %@, Primary: %@, Factory: %@, Factory Selector: %s, Return type: %s, Name: %@", finalBuilder, isPrimary ? @"YES": @"NO", isFactory ? @"YES": @"NO",sel_getName(selector) , class_getName(returnType), name);

}

-(void) registerObject:(id) object withName:(NSString *) name {
    ALCClassBuilder *instance = [[ALCClassBuilder alloc] initWithContext:self
                                                              valueClass:[object class]
                                                                    name:name];
    STLog(instance, @"Adding object %@", object);
    instance.value = object;
    [self addBuilderToModel:instance];
}

#pragma mark - Internal category

-(void) addBuilderToModel:(id<ALCBuilder> __nonnull) builder {
    [_model addBuilder:builder];
}

-(void) executeOnBuildersWithQualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers
                processingBuildersBlock:(ProcessBuilderBlock __nonnull) processBuildersBlock {
    NSSet<id<ALCBuilder>> *builders = [_model buildersMatchingQualifiers:qualifiers];
    if ([builders count] > 0) {
        processBuildersBlock(builders);
    }
}

-(nonnull id) instantiateObjectFromBuilder:(id<ALCBuilder> __nonnull) builder {

    STLog(builder.valueClass, @"Instantiating value");
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

-(nonnull id) resolveValueForDependency:(ALCDependency __nonnull *) dependency candidates:(NSSet<id<ALCBuilder>> __nonnull *)candidates {
    return [_valueResolverManager resolveValueForDependency:dependency candidates:candidates];
}

#pragma mark - Internal

-(void) resolveBuilderDependencies {
    STLog(ALCHEMIC_LOG, @"Resolving dependencies ...");
    [[_model allBuilders] enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL *stop){
        STLog(builder.valueClass, @"Resolving '%@' (%s)", builder.name, class_getName(builder.valueClass));
        [builder resolve];
    }];
}

-(void) instantiateSingletons {

    // This is a two stage process so that all objects are created before dependencies are wired up.
    STLog(ALCHEMIC_LOG, @"Instantiating singletons ...");
    NSMutableSet *singletons = [[NSMutableSet alloc] init];
    [[_model allClassBuilders] enumerateObjectsUsingBlock:^(ALCClassBuilder *classBuilder, BOOL *stop) {
        if (classBuilder.createOnStartup) {
            STLog(classBuilder, @"Creating singleton %@ -> %@", classBuilder.name, classBuilder);
            [singletons addObject:[classBuilder instantiate]];
        }
    }];

    STLog(ALCHEMIC_LOG, @"Injecting dependencies into singletons ...");
    [singletons enumerateObjectsUsingBlock:^(id singleton, BOOL *stop) {
        [self injectDependencies:singleton];
    }];
    
}

@end
