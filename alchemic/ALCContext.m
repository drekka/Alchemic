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
#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCVariableDependency.h"
#import "NSDictionary+ALCModel.h"
#import "ALCClassBuilder.h"
#import "ALCFactoryMethodBuilder.h"
#import "ALCDefaultValueProcessorFactory.h"
#import "ALCType.h"

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
        self.valueProcessorFactoryClass = [ALCDefaultValueProcessorFactory class];
    }
    return self;
}

-(void) start {
    
    logRuntime(@"Starting alchemic ...");
    [self setDefaults];
    
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

-(void) setDefaults {
    logConfig(@"Creating a Processor Factory from a %s", class_getName(self.valueProcessorFactoryClass));
    _valueProcessorFactory = [[self.valueProcessorFactoryClass alloc] init];
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

-(void) registerAsSingleton:(ALCClassBuilder *) classBuilder {
    logRegistration(@"   registering %@ as singleton", classBuilder);
    classBuilder.singleton = YES;
}

-(void) registerAsSingleton:(ALCClassBuilder *) classBuilder withName:(NSString *) name {
    classBuilder.singleton = YES;
    [_model addBuilder:classBuilder underName:name];
}

-(void) registerObject:(id) object withName:(NSString *) name {
    ALCClassBuilder *instance = [_model addObject:object inContext:self withName:name];
    logRegistration(@"Adding object %@", object);
    instance.singleton = YES;
    instance.value = object;
}

-(void) registerFactory:(ALCClassBuilder *) classBuilder
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ... {
    
    // Process the selector arguments
    va_list args;
    va_start(args, returnTypeClass);
    NSMutableArray *argumentMatchers = [[NSMutableArray alloc] init];
    id argument;
    while ((argument = va_arg(args, id)) != nil) {
        [self addMatcherArgument:argument toMatcherArray:argumentMatchers];
    }
    va_end(args);
    
    [self registerFactory:classBuilder
                 withName:nil
          factorySelector:factorySelector
               returnType:returnTypeClass
                 matchers:argumentMatchers];
}

-(void) registerFactory:(ALCClassBuilder *) classBuilder
               withName:(NSString *) name
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ... {
    
    // Process the selector arguments
    va_list args;
    va_start(args, returnTypeClass);
    NSMutableArray *argumentMatchers = [[NSMutableArray alloc] init];
    id argument;
    while ((argument = va_arg(args, id)) != nil) {
        [self addMatcherArgument:argument toMatcherArray:argumentMatchers];
    }
    va_end(args);
    
    [self registerFactory:classBuilder
                 withName:name
          factorySelector:factorySelector
               returnType:returnTypeClass
                 matchers:argumentMatchers];
}

-(void) registerFactory:(ALCClassBuilder *) classBuilder
               withName:(NSString *) name
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass
               matchers:(NSArray *) argumentMatchers {
    
    [ALCRuntime validateSelector:factorySelector withClass:classBuilder.valueType.typeClass];
    
    // Declare a new instance to represent the factory method for dependency resolving.
    ALCFactoryMethodBuilder *factoryBuilder = [_model addMethod:factorySelector
                                                      toBuilder:classBuilder
                                                     returnType:[ALCType typeForClass:returnTypeClass]
                                               argumentMatchers:argumentMatchers];
    if (name != nil) {
        [_model addBuilder:factoryBuilder underName:name];
    }
}

-(void) addMatcherArgument:(id) argument toMatcherArray:(NSMutableArray *) matcherArray {
    
    // Validate the matchers, checking any arrays.
    if ([argument isKindOfClass:[NSArray class]]) {
        for (id nestedArgument in (NSArray *) argument) {
            [ALCRuntime validateMatcher:nestedArgument];
        }
    } else {
        [ALCRuntime validateMatcher:argument];
    }
    
    [matcherArray addObject:argument];
}

@end
