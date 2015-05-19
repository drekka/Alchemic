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
#import "ALCResolvable.h"
#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCVariableDependency.h"
#import "NSDictionary+ALCModel.h"
#import "ALCResolvableObject.h"
#import "ALCResolvableMethod.h"
#import "ALCDefaultValueProcessorFactory.h"

@implementation ALCContext {
    NSMutableSet *_initialisationStrategyClasses;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        _model = [[NSMutableDictionary alloc] init];
        _initialisationStrategyClasses = [[NSMutableSet alloc] init];
        _resolverPostProcessors = [[NSMutableSet alloc] init];
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
    
    [self resolveModelObjects];
    
    logRuntime(@"Creating objects ...");
    [self instantiateSingletons];
}

-(void) setDefaults {
    logConfig(@"Creating an object resolver from a %s", class_getName(self.valueProcessorFactoryClass));
    _valueProcessorFactory = [[self.valueProcessorFactoryClass alloc] init];
}

-(void) resolveModelObjects {
    logDependencyResolving(@"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCResolvable> objectMetadata, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in '%@' (%s)", name, class_getName(objectMetadata.objectClass));
        [objectMetadata resolveDependencies];
    }];
}

-(void) instantiateSingletons {
    
    logCreation(@"Instantiating objects ...");
    [_model enumerateResolvableObjectsUsingBlock:^(NSString *name, ALCResolvableObject *resolvableObject, BOOL *stop) {
        if (resolvableObject.object == nil && resolvableObject.instantiate) {
            logCreation(@"instanting '%@' %@", name, resolvableObject);
            [resolvableObject instantiateObject];
        }
    }];
    
    logCreation(@"Injecting dependencies objects ...");
    [_model enumerateResolvableObjectsUsingBlock:^(NSString *name, ALCResolvableObject *resolvableObject, BOOL *stop) {
        if (resolvableObject.object != nil) {
            [resolvableObject injectDependenciesInto:resolvableObject.object];
        }
    }];
    
}

-(void) injectDependencies:(id) object {
    
    logRuntime(@"Injecting dependencies into a %s", object_getClassName(object));
    
    // Object will have a matching instance in the model if it has any injection point.
    ALCResolvableObject *instance = [_model findResolvableObjectForObject:object];
    
    
    [instance injectDependenciesInto:object];
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    logConfig(@"Adding object factory: %s", object_getClassName(objectFactory));
    [(NSMutableSet *)_objectFactories addObject:objectFactory];
}

-(void) addResolverPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor {
    logConfig(@"Adding resolver post processor: %s", object_getClassName(postProcessor));
    [(NSMutableSet *)_resolverPostProcessors addObject:postProcessor];
}

-(void) addInitStrategy:(Class) initialisationStrategyClass {
    logConfig(@"Adding init strategy: %s", class_getName(initialisationStrategyClass));
    [_initialisationStrategyClasses addObject:initialisationStrategyClass];
}

#pragma mark - Registration call backs

-(void) registerAsSingleton:(ALCResolvableObject *) resolvableObject {
    resolvableObject.instantiate = YES;
}

-(void) registerAsSingleton:(ALCResolvableObject *) resolvableObject withName:(NSString *) name {
    resolvableObject.instantiate = YES;
    [_model storeResolvable:resolvableObject underName:name];
}

-(void) registerObject:(id) object withName:(NSString *) name {
    ALCResolvableObject *instance = [_model addObject:object inContext:self withName:name];
    instance.instantiate = YES;
    instance.object = object;
}

-(void) registerFactory:(ALCResolvableObject *) resolvableObject
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ... {
    
    [ALCRuntime validateSelector:factorySelector withClass:resolvableObject.objectClass];
    
    // Process the selector arguments
    va_list args;
    va_start(args, returnTypeClass);
    id argument = va_arg(args, id);
    NSMutableArray *argumentMatchers = [[NSMutableArray alloc] init];
    while (argument != nil) {
        [self addMatcherArgument:argument toMatcherArray:argumentMatchers];
        argument = va_arg(args, id);
    }
    va_end(args);
    
    // Declare a new instance to represent the factory method for dependency resolving.
    ALCResolvableMethod *factoryMethod = [_model addMethod:factorySelector
                                        toResolvableObject:resolvableObject
                                                returnType:returnTypeClass
                                          argumentMatchers:argumentMatchers];
    factoryMethod.argumentMatchers = argumentMatchers;
    
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

-(void) registerFactory:(ALCResolvableObject *) resolvableObject
               withName:(NSString *) name
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ... {
    
    [ALCRuntime validateSelector:factorySelector withClass:resolvableObject.objectClass];
    
    // Process the selector arguments
    va_list args;
    va_start(args, returnTypeClass);
    id argument = va_arg(args, id);
    NSMutableArray *argumentMatchers = [[NSMutableArray alloc] init];
    while (argument != nil) {
        [self addMatcherArgument:argument toMatcherArray:argumentMatchers];
        argument = va_arg(args, id);
    }
    va_end(args);
    
    // Declare a new instance to represent the factory method for dependency resolving.
    ALCResolvableMethod *factoryMethod = [_model addMethod:factorySelector
                                        toResolvableObject:resolvableObject
                                                returnType:returnTypeClass
                                          argumentMatchers:argumentMatchers];
    [_model storeResolvable:factoryMethod underName:name];
    factoryMethod.argumentMatchers = argumentMatchers;
}

@end
