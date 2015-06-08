//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCContext.h"
#import "ALCLogger.h"
#import "ALCInternal.h"
#import "ALCInitStrategyInjector.h"
#import "ALCRuntime.h"
#import "ALCMatcher.h"
#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCVariableDependency.h"
#import "NSDictionary+ALCModel.h"
#import "ALCClassBuilder.h"
#import "ALCFactoryMethodBuilder.h"
#import "ALCDefaultValueResolverManager.h"
#import "ALCType.h"
#import "ALCReturnType.h"
#import "ALCIsSingleton.h"
#import "ALCFactoryMethodSelector.h"
#import "ALCIntoVariable.h"
#import "ALCIsPrimary.h"
#import "ALCAsName.h"

@implementation ALCContext {
    NSMutableSet *_initialisationStrategyClasses;
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

-(void) start {
    
    logRuntime(@"Starting alchemic ...");
    
    // Set defaults.
    if (self.runtimeInitInjector == nil) {
        self.runtimeInitInjector = [[ALCInitStrategyInjector alloc] initWithStrategyClasses:_initialisationStrategyClasses];
    }
    
    // Inject init wrappers into classes that have registered for dependency injection.
    [_runtimeInitInjector replaceInitsInModelClasses:_model];
    
    [self resolveBuilderDependencies];
    
    logRuntime(@"Creating singletons ...");
    [self instantiateSingletons];
}

-(void) resolveBuilderDependencies {
    logDependencyResolving(@"---- Resolving dependencies ----");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCBuilder> builder, BOOL *stop){
        logDependencyResolving(@"Resolving '%@' (%s)", name, class_getName(builder.valueType.typeClass));
        [builder resolve];
    }];
}

-(void) instantiateSingletons {
    
    logCreation(@"---- Instantiating singletons ----");
    NSMutableSet *singletonClassbuilders = [[NSMutableSet alloc] init];
    [_model enumerateClassBuildersWithBlock:^(NSString *name, ALCClassBuilder *classBuilder, BOOL *stop) {
        if (classBuilder.singleton) {
            if ([classBuilder instantiate] != nil) {
                [singletonClassbuilders addObject:classBuilder];
            }
        }
    }];
    
    logCreation(@"---- Injecting dependencies into singletons ----");
    [singletonClassbuilders enumerateObjectsUsingBlock:^(ALCClassBuilder *classBuilder, BOOL *stop) {
        [classBuilder injectDependenciesInto:classBuilder.value];
    }];
    
}

-(void) injectDependencies:(id) object {
    logRuntime(@"Injecting dependencies into a %s", object_getClassName(object));
    ALCClassBuilder *classBuilder = [_model findClassBuilderForObject:object];
    [classBuilder injectDependenciesInto:object];
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    logConfig(@"Adding object factory: %s", object_getClassName(objectFactory));
    [(NSMutableSet *)_objectFactories addObject:objectFactory];
}

-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor {
    logConfig(@"Adding dependency post processor: %s", object_getClassName(postProcessor));
    [(NSMutableSet *)_dependencyPostProcessors addObject:postProcessor];
}

-(void) addInitStrategy:(Class) initialisationStrategyClass {
    logConfig(@"Adding init strategy: %s", class_getName(initialisationStrategyClass));
    [_initialisationStrategyClasses addObject:initialisationStrategyClass];
}

#pragma mark - Registration call backs

-(void) registerDependencyInClassBuilder:(ALCClassBuilder *) classBuilder qualifiers:(id) firstQualifier, ... {
    
    NSMutableSet *matchers = [[NSMutableSet alloc] init];
    NSString *intoVariable = nil;
    
    va_list qualifiers;
    va_start(qualifiers, firstQualifier);
    id qualifier = firstQualifier;
    while (qualifier != nil) {
        
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
        
        qualifier = va_arg(qualifiers, id);
    }
    va_end(qualifiers);
    
    // Add the registration.
    [classBuilder addInjectionPoint:intoVariable withMatchers:matchers];
    
}

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder qualifiers:(id) firstQualifier, ... {
    
    Class returnType = NULL;
    BOOL isSingleton = NO;
    BOOL isPrimary = NO;
    SEL factorySelector = NULL;
    NSString *name;
    NSMutableArray *matchers = [[NSMutableArray alloc] init];
    
    va_list qualifiers;
    va_start(qualifiers, firstQualifier);
    id qualifier = firstQualifier;
    while (qualifier != nil) {
        
        // Now sort out what sort of qualifier we are dealing with.
        if ([qualifier isKindOfClass:[ALCReturnType class]]) {
            returnType = ((ALCReturnType *)qualifier).returnType;
        
        } else if ([qualifier isKindOfClass:[ALCIntoVariable class]]) {
            @throw [NSException exceptionWithName:@"AlchemicCannotUseIntoVariableHere"
                                           reason:[NSString stringWithFormat:@"Cannot use %@ in a class declaration", qualifier]
                                         userInfo:nil];
        
        } else if ([qualifier isKindOfClass:[ALCIsSingleton class]]) {
            isSingleton = YES;
        
        } else if ([qualifier isKindOfClass:[ALCIsPrimary class]]) {
            isPrimary = YES;
        
        } else if ([qualifier isKindOfClass:[ALCAsName class]]) {
            name = ((ALCAsName *) qualifier).asName;
        
        } else if ([qualifier isKindOfClass:[ALCFactoryMethodSelector class]]) {
            factorySelector = ((ALCFactoryMethodSelector *) qualifier).factorySelector;

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
        
        qualifier = va_arg(qualifiers, id);
        
    }
    va_end(qualifiers);
    
    // Add the registration.
    id<ALCBuilder> finalBuilder = classBuilder;
    if (factorySelector != NULL) {
        
        [ALCRuntime validateSelector:factorySelector withClass:classBuilder.valueType.typeClass];
        
        // Declare a new instance to represent the factory method for dependency resolving.
        finalBuilder = [_model addMethod:factorySelector
                               toBuilder:classBuilder
                              returnType:[ALCType typeForClass:returnType]
                        argumentMatchers:matchers];
    }
    
    // Set common properties.
    if (name != nil) {
        [_model addBuilder:finalBuilder underName:name];
    }
    finalBuilder.singleton = isSingleton;
    finalBuilder.primary = isPrimary;
    
}

-(void) registerObject:(id) object withName:(NSString *) name {
    ALCClassBuilder *instance = [_model addObject:object inContext:self withName:name];
    logRegistration(@"Adding object %@", object);
    instance.singleton = YES;
    instance.value = object;
}

@end
