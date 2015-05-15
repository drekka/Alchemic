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
#import "ALCObjectMetadata.h"
#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCVariableDependency.h"
#import "NSDictionary+ALCModel.h"
#import "ALCInstance.h"
#import "ALCFactoryMethod.h"

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
        _dependencyInjectors = [[NSMutableArray alloc] init];
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
    
    [self resolveModelObjects];

    logRuntime(@"Creating objects ...");
    [self instantiateModelObjects];
}

-(void) resolveModelObjects {
    logDependencyResolving(@"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCObjectMetadata> objectMetadata, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in '%@' (%s)", name, class_getName(objectMetadata.objectClass));
        [objectMetadata resolveDependencies];
    }];
}

-(void) instantiateModelObjects {
    logCreation(@"Instantiating objects ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCObjectMetadata> object, BOOL *stop) {
        [object instantiateObject];
    }];
}

-(void) injectDependencies:(id) object {
    
    logRuntime(@"Injecting dependencies into a %s", object_getClassName(object));
    
    // Object will have a matching instance in the model if it has any injection point.
    ALCInstance *instance = [_model instanceForObject:object];
    
    
    [instance injectDependenciesInto:object];
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    logConfig(@"Adding object factory: %s", object_getClassName(objectFactory));
    [(NSMutableSet *)_objectFactories addObject:objectFactory];
}

-(void) addDependencyInjector:(id<ALCDependencyInjector>) dependencyinjector {
    logConfig(@"Adding dependency injector: %s", object_getClassName(dependencyinjector));
    [(NSMutableArray *)_dependencyInjectors addObject:dependencyinjector];
    [(NSMutableArray *)_dependencyInjectors sortUsingComparator:^NSComparisonResult(ALCAbstractDependencyInjector *di1, ALCAbstractDependencyInjector *di2) {
        if (di1.order > di2.order) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (di1.order < di2.order) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

-(void) addResolverPostProcessor:(id<ALCResolverPostProcessor>) postProcessor {
    logConfig(@"Adding resolver post processor: %s", object_getClassName(postProcessor));
    [(NSMutableSet *)_resolverPostProcessors addObject:postProcessor];
}

-(void) addInitStrategy:(Class) initialisationStrategyClass {
    logConfig(@"Adding init strategy: %s", class_getName(initialisationStrategyClass));
    [_initialisationStrategyClasses addObject:initialisationStrategyClass];
}

#pragma mark - Registration call backs

-(void) registerAsSingleton:(ALCInstance *) objectInstance {
    objectInstance.instantiate = YES;
}

-(void) registerAsSingleton:(ALCInstance *) objectInstance withName:(NSString *) name {
    objectInstance.instantiate = YES;
    [_model indexMetadata:objectInstance underName:name];
}

-(void) registerObject:(id) object withName:(NSString *) name {
    ALCInstance *instance = [_model addObject:object inContext:self withName:name];
    instance.instantiate = YES;
    instance.object = object;
}

-(void) registerFactory:(ALCInstance *) objectInstance
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ... {
    
    [ALCRuntime validateSelector:factorySelector withClass:objectInstance.objectClass];
    
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
    ALCFactoryMethod *factoryMethod = [_model addFactoryMethod:factorySelector
                                                    toInstance:objectInstance
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

-(void) registerFactory:(ALCInstance *) objectInstance
               withName:(NSString *) name
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ... {

    [ALCRuntime validateSelector:factorySelector withClass:objectInstance.objectClass];
    
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
    ALCFactoryMethod *factoryMethod = [_model addFactoryMethod:factorySelector
                                                    toInstance:objectInstance
                                                    returnType:returnTypeClass
                                              argumentMatchers:argumentMatchers];
    [_model indexMetadata:factoryMethod underName:name];
    factoryMethod.argumentMatchers = argumentMatchers;
}

@end
