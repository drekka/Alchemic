//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

#import "ALCInitStrategyInjector.h"
#import "ALCRuntime.h"
#import "NSDictionary+ALCModel.h"
#import "ALCClassBuilder.h"
#import "ALCMethodBuilder.h"
#import "ALCDefaultValueResolverManager.h"
#import "ALCType.h"
#import "ALCIsFactory.h"

@implementation ALCContext {
    NSMutableSet<Class> *_initialisationStrategyClasses;
    NSDictionary<NSString *, NSSet<id<ALCBuilder>> *> *_model;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        _model = [[NSMutableDictionary alloc] init];
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
    [_runtimeInitInjector replaceInitsInModelClasses:_model];

    [self resolveBuilderDependencies];

    STLog(ALCHEMIC_LOG, @"Creating singletons ...");
    [self instantiateSingletons];
}

-(void) injectDependencies:(id) object {
    ALCClassBuilder *classBuilder = [_model findClassBuilderForObject:object];
    STLog(classBuilder, @"Injecting dependencies into a %s", [object class]);
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

    NSMutableSet *matchers = [[NSMutableSet alloc] init];
    NSString *intoVariable = nil;

    va_list qualifiers;
    va_start(qualifiers, classBuilder);
    id qualifier;
    while ((qualifier = va_arg(qualifiers, id)) != nil) {

        if ([qualifier isKindOfClass:[ALCIntoVariable class]]) {
            intoVariable = ((ALCIntoVariable *) qualifier).variableName;

        } else if ([qualifier conformsToProtocol:@protocol(ALCMatcher)]) {
            id<ALCMatcher> matcher = (id<ALCMatcher>) qualifier;
            [ALCRuntime validateMatcher:matcher];
            [matchers addObject:matcher];

        } else {
            @throw [NSException exceptionWithName:@"AlchemicUnexpectedQualifier"
                                           reason:[NSString stringWithFormat:@"Unexpected qualifier %@ for a variable declaration.", qualifier]
                                         userInfo:nil];
        }
    }
    va_end(qualifiers);

    // Add the registration.
    [classBuilder addInjectionPoint:intoVariable withMatchers:[matchers count] == 0 ? nil : matchers];

}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... {

    Class returnType = NULL;
    BOOL isFactory = NO;
    BOOL isPrimary = NO;
    SEL methodSelector = NULL;
    NSString *name;
    NSMutableArray *matchers = [[NSMutableArray alloc] init];

    va_list qualifiers;
    va_start(qualifiers, classBuilder);
    id qualifier;
    while ((qualifier = va_arg(qualifiers, id)) != nil) {

        // Now sort out what sort of qualifier we are dealing with.
        if ([qualifier isKindOfClass:[ALCReturnType class]]) {
            returnType = ((ALCReturnType *)qualifier).returnType;

        } else if ([qualifier isKindOfClass:[ALCIntoVariable class]]) {
            @throw [NSException exceptionWithName:@"AlchemicCannotUseIntoVariableHere"
                                           reason:[NSString stringWithFormat:@"Cannot use %@ in a class declaration", qualifier]
                                         userInfo:nil];

        } else if ([qualifier isKindOfClass:[ALCIsFactory class]]) {
            isFactory = YES;

        } else if ([qualifier isKindOfClass:[ALCIsPrimary class]]) {
            isPrimary = YES;

        } else if ([qualifier isKindOfClass:[ALCAsName class]]) {
            name = ((ALCAsName *) qualifier).asName;

        } else if ([qualifier isKindOfClass:[ALCMethodSelector class]]) {
            methodSelector = ((ALCMethodSelector *) qualifier).factorySelector;

        } else if ([qualifier conformsToProtocol:@protocol(ALCMatcher)]) {

            // Validate the matchers, checking any arrays.
            if ([qualifier isKindOfClass:[NSArray class]]) {
                for (id nestedQualifier in (NSArray *) qualifier) {
                    [ALCRuntime validateMatcher:nestedQualifier];
                }
            } else {
                [ALCRuntime validateMatcher:qualifier];
            }

            [matchers addObject:qualifier];
        }

    }
    va_end(qualifiers);

    // Add the registration.
    id<ALCBuilder> finalBuilder = classBuilder;
    if (methodSelector != NULL) {

        [ALCRuntime validateSelector:methodSelector withClass:classBuilder.valueType.typeClass];

        // Declare a new instance to represent the factory method for dependency resolving.
        finalBuilder = [_model addMethod:methodSelector
                               toBuilder:classBuilder
                              returnType:[ALCType typeForClass:returnType]
                        argumentMatchers:matchers];
    }

    // Set common properties.
    if (name != nil) {
        [_model addBuilder:finalBuilder underName:name];
    }
    finalBuilder.factory = isFactory;
    finalBuilder.primary = isPrimary;
    finalBuilder.createOnStartup = !isFactory;

    STLog(finalBuilder, @"Setting up: %@, Primary: %@, Factory: %@, Factory Selector: %s, Return type: %s, Name: %@", finalBuilder, isPrimary ? @"YES": @"NO", isFactory ? @"YES": @"NO",sel_getName(methodSelector) , class_getName(returnType), name);

}

-(void) registerObject:(id) object withName:(NSString *) name {
    ALCClassBuilder *instance = [_model addObject:object inContext:self withName:name];
    STLog(instance, @"Adding object %@", object);
    instance.value = object;
}

#pragma mark - Internal

-(void) resolveBuilderDependencies {
    STLog(ALCHEMIC_LOG, @"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCBuilder> builder, BOOL *stop){
        STLog(builder, @"Resolving '%@' (%s)", name, class_getName(builder.valueType.typeClass));
        [builder resolve];
    }];
}

-(void) instantiateSingletons {

    // This is a two stage process so that all objects are created before dependencies are wired up.
    STLog(ALCHEMIC_LOG, @"Instantiating singletons ...");
    NSMutableSet *singletons = [[NSMutableSet alloc] init];
    [_model enumerateClassBuildersWithBlock:^(NSString *name, ALCClassBuilder *classBuilder, BOOL *stop) {
        if (classBuilder.shouldCreateOnStartup) {
            STLog(classBuilder, @"Creating singleton %@ -> %@", name, classBuilder);
            [singletons addObject:[classBuilder instantiate]];
        }
    }];

    STLog(ALCHEMIC_LOG, @"Injecting dependencies into singletons ...");
    [singletons enumerateObjectsUsingBlock:^(id singleton, BOOL *stop) {
        [self injectDependencies:singleton];
    }];
    
}

@end
